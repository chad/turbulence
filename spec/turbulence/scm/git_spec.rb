require 'turbulence/scm/git'
require 'tmpdir'
require 'fileutils'

describe Turbulence::Scm::Git do
  describe "::is_repo?" do
    before do
      # Create temp dir in system temp location (outside any git repo)
      @tmp = Dir.mktmpdir('turbulence-test')
    end
    after do
      FileUtils.remove_entry(@tmp)
    end
    it "returns true for the working directory" do
      expect(Turbulence::Scm::Git.is_repo?(".")).to eq true
    end
    it "return false for a newly created tmp directory" do
      expect(Turbulence::Scm::Git.is_repo?(@tmp)).to eq false
    end
  end

  describe "::log_command" do
    it "takes an optional argument specify to the range" do
      expect { Turbulence::Scm::Git.log_command("d551e63f79a90430e560ea871f4e1e39e6e739bd  HEAD") }.to_not raise_error
    end
    it "lists insertions/deletions per file and change" do
      expect(Turbulence::Scm::Git.log_command).to match(/\d+\t\d+\t[A-z.]*/)
    end
  end
end
