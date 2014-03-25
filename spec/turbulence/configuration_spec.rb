require 'rspec'
require 'turbulence'

describe Turbulence::Configuration do
  describe "defaults" do
    its(:output)     { should eq(STDOUT) }
    its(:directory)  { should eq(Dir.pwd) }
    its(:graph_type) { should eq('turbulence') }
    its(:scm_name)   { should eq('Git') }
    its(:scm)        { should eq(Turbulence::Scm::Git) }
  end
end

