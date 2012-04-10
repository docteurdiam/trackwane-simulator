# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  gem.executables = "trackwane-simulator"
  gem.name = "trackwane-simulator"
  gem.homepage = "http://github.com/okouam/trackwane-simulator"
  gem.license = "MIT"
  gem.summary = %Q{sds: one-line summary of your gem}
  gem.description = %Q{sdsd: longer description of your gem}
  gem.email = "olivier.kouame@gmail.com"
  gem.authors = ["Olivier Kouame"]
end
Jeweler::RubygemsDotOrgTasks.new
