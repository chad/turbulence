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

  describe "::log_command" do
    it "takes an optional argument specify to the range" do
      expect{Turbulence::Scm::Git.log_command("d551e63f79a90430e560ea871f4e1e39e6e739bd  HEAD")}.to_not raise_error(ArgumentError)
    end
    it "lists insertions/deletions per file and change" do
      Turbulence::Scm::Git.log_command.should match(/\d+\t\d+\t[A-z.]*/)
    end
  end
end
