# encoding: utf-8
#
require 'heroku'
require 'pgbackups/client'
require 'fog'

class HerokuS3Backup
  def self.backup(options = {})
    begin
      puts "[#{Time.now}] heroku:backup started"

      # Set app
      if options[:name] == false
        app = ""
      elsif options[:name].present?
        app = options[:name]
      else
        app = ENV['APP_NAME']
      end

      # Set bucket
      bucket = if options[:bucket]
        options[:bucket]
      else
        "#{app}-heroku-backups"
      end

      # Set path
      path = if options[:path]
        options[:path]
      else
        "db"
      end

      # Set timestamp
      timestamp = if options[:timestamp]
        options[:timestamp]
      else
        "%Y-%m-%d-%H%M%S"
      end

      name = "#{app}-#{Time.now.strftime(timestamp)}.sql"

      db = ENV['DATABASE_URL'].match(/postgres:\/\/([^:]+):([^@]+)@([^\/]+)\/(.+)/)

      # Create backup using pgbackup and auto expire oldest backup as required
      puts "creating backup"
      pgbackup = PGBackups::Client.new(ENV["PGBACKUPS_URL"])
      pgbackup.create_transfer(ENV['SHARED_DATABASE_URL'], ENV['DATABASE_URL'], nil, 'BACKUP', :expire => true)

      # Save latest backup locally
      puts "saving last backup locally"
      url = URI.parse(pgbackup.get_latest_backup['public_url'])
      system "curl -o tmp/#{name} #{url}"
      # File.open("tmp/#{name}", 'wb') {|f| f.write(Net::HTTP.get_response(url).body) }

      puts "gzipping sql file..."
      `gzip tmp/#{name}`

      backup_path = "tmp/#{name}.gz"

      begin
        s3_creds = YAML::load_file("#{Rails.root}/config/s3.yml")
        s3_key = s3_creds[Rails.env]['access_key_id']
        s3_secret = s3_creds[Rails.env]['secret_access_key']
      rescue
        s3_key = ENV['S3_KEY']
        s3_secret = ENV['S3_SECRET']
      end

      puts "login-in to s3..."
      s3 = Fog::Storage.new(
        :provider => 'AWS',
        :aws_access_key_id => s3_key,
        :aws_secret_access_key => s3_secret
      )
      s3.get_service

      begin
        puts "getting bucket: #{bucket}"
        s3.get_bucket(bucket)
        directory = s3.directories.get(bucket)
      rescue Excon::Errors::NotFound
        puts "creating bucket: #{bucket}"
        directory = s3.directories.create(:key => bucket)
        s3.get_bucket(bucket)
      end

      puts "saving backup to s3..."
      directory.files.create(:key => "#{path}/#{name}.gz", :body => open(backup_path))

      puts "cleaning local backup cache..."
      system "rm #{backup_path}"

      # Remove old backups
      if options[:limit]
        directory = s3.directories.get(bucket)
        backups = directory.files.find_all { |file| file.key.match(/#{path}\/#{app}-.*\.sql\.gz/) }
        if backups.size > options[:limit]
          puts "removing old backups..."
          backups.sort! { |a, b| b.last_modified <=> a.last_modified }
          backups[options[:limit]..-1].each { |file| file.destroy }
        end
      end

      puts "[#{Time.now}] heroku:backup complete"

    rescue Exception => e
      if ENV['HOPTOAD_KEY']
        require 'toadhopper'
        Toadhopper(ENV['HOPTOAD_KEY']).post!(e)
      else
        puts "S3 backup error: #{e}"
      end
    end
  end
end
