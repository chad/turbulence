require 'turbulence'

describe Turbulence::CommandLineInterface do
  let(:cli) { Turbulence::CommandLineInterface.new('.') }
  describe "#path_to_template" do
    it "returns a path" do
      cli.path_to_template('file').should eq(Turbulence::CommandLineInterface::TURBULENCE_PATH + '/template/file')
    end
  end
  describe "#generate_bundle" do
    it "bundles the files" do
      cli.generate_bundle 
      Dir.glob('turbulence/*').should eq(["turbulence/cc.js", "turbulence/highcharts.js", "turbulence/jquery.min.js", "turbulence/turbulence.html"])
    end
  end
end
