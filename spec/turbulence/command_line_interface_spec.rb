require 'rspec'
require 'turbulence'

describe Turbulence::CommandLineInterface do
  let(:cli) { Turbulence::CommandLineInterface.new(%w(.)) }
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
      Dir.glob('turbulence/*').should eq(["turbulence/cc.js", "turbulence/highcharts.js", "turbulence/jquery.min.js", "turbulence/turbulence.html"])
    end
  end
  describe "command line options" do
    let(:cli_churn_range) { Turbulence::CommandLineInterface.new(%w(--churn-range f3e1d7a6..830b9d3d9f path/to/compute)) }
    let(:cli_churn_mean) { Turbulence::CommandLineInterface.new(%w(--churn-mean .)) }

    it "sets churn range" do
      cli_churn_range.directory.should == 'path/to/compute'
      Turbulence::Calculators::Churn.commit_range.should == 'f3e1d7a6..830b9d3d9f'
    end
    
    it "sets churn mean" do
      cli_churn_mean.directory.should == '.'
      Turbulence::Calculators::Churn.compute_mean.should be_true
    end
  end
end
