require 'bundler'
require File.join(File.dirname(__FILE__), 'win_rakefile_location_fix')
Bundler::GemHelper.install_tasks
require 'rake'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |t|
  t.skip_bundler = true
end

task :default => [:spec]
