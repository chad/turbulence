require 'rake'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |t|
  t.skip_bundler = true
end

task :default => [:spec]
