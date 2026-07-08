require 'fileutils'
require 'json'
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
    end

    extend Forwardable
    def_delegators :Turbulence, :config
    def_delegators :config, *[
      :directory,
      :graph_type,
      :exclusion_pattern,
      :no_open,
      :output_dir,
      :json_output,
    ]

    def output_path
      output_dir || File.join(Dir.pwd, "turbulence")
    end

    def copy_templates_into(directory)
      FileUtils.cp TEMPLATE_FILES, directory
    end

    def generate_bundle
      if json_output
        generate_json
      else
        generate_html
      end
    end

    def generate_json
      # Suppress progress output for clean JSON
      config.output = nil
      turb = Turbulence.new(config)
      puts JSON.pretty_generate(turb.metrics)
    end

    def generate_html
      FileUtils.mkdir_p(output_path)

      Dir.chdir(output_path) do
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
      Launchy.open("file:///#{output_path}/#{graph_type}.html")
    end
  end
end
