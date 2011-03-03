require 'turbulence/scm/git'
require 'tmpdir'
require 'fileutils'

describe Turbulence::Scm::Git do
  describe "::is_repo?" do
    before do
      @tmp = Dir.mktmpdir(nil,'..')
    end
    after do
      FileUtils.rmdir(@tmp)
    end
    it "returns true for the working directory" do
      Turbulence::Scm::Git.is_repo?(".").should == true
    end
    it "return false for a newly created tmp directory" do
      Turbulence::Scm::Git.is_repo?(@tmp).should == false
    end
  end
end
