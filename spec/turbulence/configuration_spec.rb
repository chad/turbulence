require 'rspec'
require 'rspec/its'
require 'turbulence'

describe Turbulence::Configuration do
  describe "defaults" do
    its(:output)            { should eq(STDOUT) }
    its(:directory)         { should eq(Dir.pwd) }
    its(:graph_type)        { should eq('turbulence') }
    its(:scm_name)          { should eq('Git') }
    its(:scm)               { should eq(Turbulence::Scm::Git) }
    its(:no_open)           { should eq(false) }
    its(:output_dir)        { should be_nil }
    its(:commit_range)      { should be_nil }
    its(:compute_mean)      { should be_nil }
    its(:exclusion_pattern) { should be_nil }
  end
end

