require 'turbulence/scm/perforce'

describe Turbulence::Scm::Perforce do
  describe "::is_repo?" do
    it "returns true if P4CLIENT is set " do
      ENV['P4CLIENT'] = "c-foo.bar"
      Turbulence::Scm::Perforce.is_repo?(".").should == true
    end
    it "return false if P4CLIENT is empy"  do
      ENV['P4CLIENT'] = ""
      Turbulence::Scm::Perforce.is_repo?(".").should == false
    end
  end
end
