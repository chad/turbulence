require 'rspec'
require 'turbulence'

describe Turbulence::ChecksEnvironment do

  it "should determine if the current directory is a git repository" do
    Turbulence::ChecksEnvironment.git_repo?(Dir.pwd).should be_true

  end    
end
