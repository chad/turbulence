# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "chuggle/version"

Gem::Specification.new do |s|
  s.name        = "chuggle"
  s.version     = Chuggle::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Chad Fowler"]
  s.email       = ["chad@chadfowler.com"]
  s.homepage    = "http://chadfowler.com"
  s.add_dependency "flog", "= 2.5.0"
  s.add_dependency "json", "= 1.4.6"

  s.summary     = %q{Automates churn + flog scoring on a git repo for a Ruby project}
  s.description = %q{Based on this http://www.stickyminds.com/sitewide.asp?Function=edetail&ObjectType=COL&ObjectId=16679&tth=DYN&tt=siteemail&iDyn=2}

  s.rubyforge_project = "chuggle"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
