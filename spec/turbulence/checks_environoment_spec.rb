require 'rspec'
require 'turbulence/scm/git'
require 'turbulence'

describe Turbulence::ChecksEnvironment do

  it "should determine if the current directory is a git repository" do
    Turbulence::Calculators::Churn.scm = Turbulence::Scm::Git
    Turbulence::ChecksEnvironment.scm_repo?(Dir.pwd).should be_true
  end    
end
