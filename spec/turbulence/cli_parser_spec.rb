require 'rspec'
require 'turbulence'

describe Turbulence::CommandLineInterface::ConfigParser do
  let(:config) { Turbulence::Configuration.new }

  def parse(argv)
    described_class.parse_argv_into_config(argv, config)
  end

  it "sets directory" do
    parse %w( path/to/compute )
    expect(config.directory).to eq 'path/to/compute'
  end

  it "sets SCM name to 'Perforce'" do
    parse %w( --scm p4 )
    expect(config.scm_name).to eq 'Perforce'
  end

  it "sets commit range" do
    parse %w( --churn-range f3e1d7a6..830b9d3d9f )
    expect(config.commit_range).to eq 'f3e1d7a6..830b9d3d9f'
  end

  it "sets compute mean" do
    parse %w( --churn-mean )
    expect(config.compute_mean).to be true
  end

  it "sets the exclusion pattern" do
    parse %w( --exclude turbulence )
    expect(config.exclusion_pattern).to eq 'turbulence'
  end

  it "sets the graph type" do
    parse %w( --treemap )
    expect(config.graph_type).to eq 'treemap'
  end
end
