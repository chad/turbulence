require 'fileutils'
require 'launchy'
require 'optparse'
require 'forwardable'

require 'turbulence/configuration'
require 'turbulence/cli_parser'
require 'turbulence/scm/git'
require 'turbulence/scm/perforce'

class Turbulence
  class CommandLineInterface
    TURBULENCE_TEMPLATE_PATH = File.join(File.expand_path(File.dirname(__FILE__)), "..", "..", "template")
    TEMPLATE_FILES = [
      'turbulence.html',
      'highcharts.js',
      'jquery.min.js',
      'treemap.html',
    ].map do |filename|
      File.join(TURBULENCE_TEMPLATE_PATH, filename)
    end

    def initialize(argv, additional_options = {})
      ConfigParser.parse_argv_into_config argv, config
      config.output = additional_options.fetch(:output, STDOUT)
      churn_calculator.config = config
    end

    extend Forwardable
    def_delegators :config, *[
      :directory,
      :graph_type,
      :exclusion_pattern,
    ]

    def copy_templates_into(directory)
      FileUtils.cp TEMPLATE_FILES, directory
    end

    def generate_bundle
      FileUtils.mkdir_p("turbulence")

      Dir.chdir("turbulence") do
        turb = Turbulence.new(config)

        generator = case graph_type
        when "treemap"
          Turbulence::Generators::TreeMap.new({})
        else
          Turbulence::Generators::ScatterPlot.new({})
        end

        generator.generate_results(turb.metrics, self)
      end
    end

    def open_bundle
      Launchy.open("file:///#{directory}/turbulence/#{graph_type}.html")
    end

    def config
      @config ||= Turbulence::Configuration.new
    end

    private

    def churn_calculator
      Turbulence::Calculators::Churn
    end
  end
end
