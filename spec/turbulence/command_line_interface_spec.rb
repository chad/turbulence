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

    it "outputs to custom directory when --output is specified" do
      custom_dir = 'tmp/custom_output'
      FileUtils.remove_dir(custom_dir, true)
      cli = Turbulence::CommandLineInterface.new(['--output', custom_dir], :output => nil)
      cli.generate_bundle
      expect(Dir.glob("#{custom_dir}/*").sort).to eq(["#{custom_dir}/cc.js",
                                                       "#{custom_dir}/highcharts.js",
                                                       "#{custom_dir}/jquery.min.js",
                                                       "#{custom_dir}/treemap.html",
                                                       "#{custom_dir}/turbulence.html"])
      FileUtils.remove_dir(custom_dir, true)
    end
  end

  describe "#output_path" do
    before do
      # Reset the singleton config between tests
      Turbulence.instance_variable_set(:@config, nil)
    end

    it "defaults to ./turbulence when output_dir is not set" do
      cli = Turbulence::CommandLineInterface.new(%w(.), :output => nil)
      expect(cli.output_path).to eq(File.join(Dir.pwd, "turbulence"))
    end

    it "returns the custom output_dir when set" do
      cli = Turbulence::CommandLineInterface.new(%w(--output custom/path), :output => nil)
      expect(cli.output_path).to eq('custom/path')
    end
  end
end
