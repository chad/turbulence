require 'rspec'
require 'turbulence'

describe Turbulence::CommandLineInterface do
  let(:cli) { Turbulence::CommandLineInterface.new(%w(.), :output => nil) }

  describe "::TEMPLATE_FILES" do
    Turbulence::CommandLineInterface::TEMPLATE_FILES.each do |template_file|
      it "has #{File.basename(template_file)} in the template path" do
        expect(File.dirname(template_file)).to eq Turbulence::CommandLineInterface::TURBULENCE_TEMPLATE_PATH
      end
    end
  end

  describe "#generate_bundle" do
    before do
      FileUtils.remove_dir("turbulence", true)
    end
    it "bundles the files" do
      cli.generate_bundle
      expect(Dir.glob('turbulence/*').sort).to eq(["turbulence/cc.js",
                                                   "turbulence/highcharts.js",
                                                   "turbulence/jquery.min.js",
                                                   "turbulence/treemap.html",
                                                   "turbulence/turbulence.html"])
    end

    it "passes along exclusion pattern" do
      cli = Turbulence::CommandLineInterface.new(%w(--exclude turbulence), :output => nil)
      cli.generate_bundle
      lines = File.new('turbulence/cc.js').readlines
      expect(lines.any? { |l| l =~ /turbulence\.rb/ }).to be false
    end
  end
end
