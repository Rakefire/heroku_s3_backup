# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{heroku_s3_backup}
  s.version = "0.0.7"
  s.platform    = Gem::Platform::RUBY
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Eric Davis", "Trevor Turk", "Jesse Storimer", "Jack Chu", "Patrick Crowley", "Sebastien Grosjean", "Matthew O'Riordan"]
  s.date = %q{2011-02-01}
  s.description = %q{http://trevorturk.com/2010/04/14/automated-heroku-backups/ My fork replaces right_aws/aws-s3 with the fog gem and support Cedar stack}
  s.email = %q{me@mattheworiordan.com}
  s.extra_rdoc_files = [
    "LICENSE",
    "README.rdoc"
  ]
  s.files = [
    "LICENSE",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "lib/heroku_s3_backup.rb",
    "lib/tasks/heroku.rake",
    "test/helper.rb",
    "test/test_heroku_s3_backup.rb"
  ]
  s.homepage = %q{http://github.com/ZenCocoon/heroku_s3_backup}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.4.2}
  s.summary = %q{Gem to backup your database from Heroku to S3. Fork uses the fog gem. Support Cedar stack}
  s.test_files = [
    "test/helper.rb",
    "test/test_heroku_s3_backup.rb"
  ]

  if s.respond_to?(:specification_version) && Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    s.specification_version = 3
    s.add_development_dependency(%q<thoughtbot-shoulda>, [">= 0"])
    s.add_runtime_dependency(%q<fog>, [">= 0.4.1"])
    s.add_runtime_dependency(%q<heroku>, [">= 2.33"])
  else
    s.add_dependency(%q<thoughtbot-shoulda>, [">= 0"])
    s.add_dependency(%q<fog>, [">= 0.4.1"])
    s.add_dependency(%q<heroku>, [">= 2.33"])
  end
end
