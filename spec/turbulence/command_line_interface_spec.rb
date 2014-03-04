require 'rspec'
require 'turbulence'

describe Turbulence::CommandLineInterface do
  let(:cli) { Turbulence::CommandLineInterface.new(%w(.), :output => nil) }
  describe "::TEMPLATE_FILES" do
    Turbulence::CommandLineInterface::TEMPLATE_FILES.each do |template_file|
      File.dirname(template_file).should == Turbulence::CommandLineInterface::TURBULENCE_TEMPLATE_PATH
    end
  end
  describe "#generate_bundle" do
    before do
      FileUtils.remove_dir("turbulence", true)
    end
    it "bundles the files" do
      cli.generate_bundle
      Dir.glob('turbulence/*').sort.should eq(["turbulence/cc.js",
                                               "turbulence/highcharts.js",
                                               "turbulence/jquery.min.js",
                                               "turbulence/treemap.html",
                                               "turbulence/turbulence.html"])
    end

    it "passes along exclusion pattern" do
      cli = Turbulence::CommandLineInterface.new(%w(--exclude turbulence), :output => nil)
      cli.generate_bundle
      lines = File.new('turbulence/cc.js').readlines
      lines.any? { |l| l =~ /turbulence\.rb/ }.should be_false
    end
  end
  describe "command line options" do
    let(:cli_churn_range) { Turbulence::CommandLineInterface.new(%w(--churn-range f3e1d7a6..830b9d3d9f path/to/compute)) }
    let(:cli_churn_mean) { Turbulence::CommandLineInterface.new(%w(--churn-mean .)) }
    let(:cli_exclusion_pattern) { Turbulence::CommandLineInterface.new(%w(--exclude turbulence)) }

    it "sets churn range" do
      cli_churn_range.directory.should == 'path/to/compute'
      Turbulence::Calculators::Churn.commit_range.should == 'f3e1d7a6..830b9d3d9f'
    end

    it "sets churn mean" do
      cli_churn_mean.directory.should == '.'
      Turbulence::Calculators::Churn.compute_mean.should be_true
    end

    it "sets the exclusion pattern" do
      cli_exclusion_pattern.exclusion_pattern.should == 'turbulence'
    end
  end
end
