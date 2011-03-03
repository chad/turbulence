require 'turbulence/scm/perforce'
require 'rspec/mocks'

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
  describe "::log_command" do
    let(:p4) { RSpec::Mocks::Mock.new("perforce").as_null_object}

    before do
      p4.stub(:connect).and_return true
    end
    it "takes an optional argument to specify the range" do
      expect{Turbulence::Scm::Perforce.log_command("@1,2",p4)}.to_not raise_error(ArgumentError)
    end

    it "lists insertions/deletions per file and change" do
      Turbulence::Scm::Perforce.log_command("",p4).should match(/\d+\t\d+\t[A-z.]*/)
    end
  end
end
