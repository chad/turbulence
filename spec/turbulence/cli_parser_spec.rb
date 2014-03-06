require 'rspec'
require 'turbulence'

describe Turbulence::CommandLineInterface::ConfigParser do
  let(:config) { Turbulence::Configuration.new }

  def parse(argv)
    described_class.parse_argv_into_config(argv, config)
  end

  it "sets directory" do
    parse %w( path/to/compute )
    config.directory.should == 'path/to/compute'
  end

  it "sets SCM name to 'Perforce'" do
    parse %w( --scm p4 )
    config.scm_name.should == 'Perforce'
  end

  it "sets commit range" do
    parse %w( --churn-range f3e1d7a6..830b9d3d9f )
    config.commit_range.should eq('f3e1d7a6..830b9d3d9f')
  end

  it "sets compute mean" do
    parse %w( --churn-mean )
    config.compute_mean.should be_true
  end

  it "sets the exclusion pattern" do
    parse %w( --exclude turbulence )
    config.exclusion_pattern.should == 'turbulence'
  end

  it "sets the graph type" do
    parse %w( --treemap )
    config.graph_type.should == 'treemap'
  end
end
