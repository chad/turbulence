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
    # TODO: Remove these specs once
    #       Turbulence::Calculators::Churn
    #       stops being a singleton
    def invoke_with_flags(argv)
      described_class.new(argv)
    end

    it "sets SCM to perforce" do
      invoke_with_flags %w(--scm p4)
      Turbulence::Calculators::Churn.scm.should == Turbulence::Scm::Perforce
    end

    it "sets churn range" do
      invoke_with_flags %w(--churn-range f3e1d7a6..830b9d3d9f)
      Turbulence::Calculators::Churn.commit_range.should == 'f3e1d7a6..830b9d3d9f'
    end

    it "sets churn mean" do
      invoke_with_flags %w(--churn-mean)
      Turbulence::Calculators::Churn.compute_mean.should be_true
    end
  end
end
