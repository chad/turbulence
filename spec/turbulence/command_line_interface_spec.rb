require 'rspec'
require 'turbulence'

describe Turbulence::CommandLineInterface do
  let(:cli) { Turbulence::CommandLineInterface.new('.') }
  describe "::TEMPLATE_FILES" do
    Turbulence::CommandLineInterface::TEMPLATE_FILES.each do |template_file|
      File.dirname(template_file).should == Turbulence::CommandLineInterface::TURBULENCE_TEMPLATE_PATH
    end
  end
  describe "#generate_bundle" do
    it "bundles the files" do
      cli.generate_bundle
      Dir.glob('turbulence/*').should eq(["turbulence/cc.js", "turbulence/highcharts.js", "turbulence/jquery.min.js", "turbulence/turbulence.html"])
    end
  end
end
