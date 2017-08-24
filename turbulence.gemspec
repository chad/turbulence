# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "turbulence/version"

Gem::Specification.new do |s|
  s.name        = "turbulence"
  s.version     = Turbulence::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Chad Fowler", "Michael Feathers", "Corey Haines"]
  s.email       = ["chad@chadfowler.com", "mfeathers@obtiva.com", "coreyhaines@gmail.com"]
  s.homepage    = "http://chadfowler.com"
  s.add_dependency "flog", "~>4.1"
  s.add_dependency "json", ">= 1.4.6"
  s.add_dependency "launchy", ">= 2.0.0"
  s.add_development_dependency 'rspec', '~> 2.14.0'
  s.add_development_dependency 'rake'

  s.summary     = %q{Automates churn + flog scoring on a git repo for a Ruby project}
  s.description = %q{Automates churn + flog scoring on a git repo for a Ruby project. Based on the article https://www.stickyminds.com/article/getting-empirical-about-refactoring}

  s.rubyforge_project = "turbulence"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.required_ruby_version = '>= 1.8.7'
end
