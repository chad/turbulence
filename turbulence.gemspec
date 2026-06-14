# frozen_string_literal: true

$:.push File.expand_path("../lib", __FILE__)
require "turbulence/version"

Gem::Specification.new do |s|
  s.name        = "turbulence"
  s.version     = Turbulence::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Chad Fowler", "Michael Feathers", "Corey Haines"]
  s.email       = ["chad@chadfowler.com", "mfeathers@obtiva.com", "coreyhaines@gmail.com"]
  s.homepage    = "https://github.com/chad/turbulence"
  s.license     = "MIT"

  s.add_dependency "flog", ">= 4.1"
  s.add_dependency "json"
  s.add_dependency "launchy", ">= 2.0.0"
  s.add_dependency "racc"  # Required by flog's ruby_parser, removed from stdlib in Ruby 3.3+

  s.add_development_dependency 'rspec', '~> 3.0'
  s.add_development_dependency 'rspec-its'
  s.add_development_dependency 'rake'

  s.summary     = %q{Automates churn + flog scoring on a git repo for a Ruby project}
  s.description = %q{Automates churn + flog scoring on a git repo for a Ruby project. Based on the article https://www.stickyminds.com/article/getting-empirical-about-refactoring}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.required_ruby_version = '>= 3.0'
end
