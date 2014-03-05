require 'fileutils'
require 'launchy'
require 'optparse'
require 'turbulence/configuration'
require 'turbulence/scm/git'
require 'turbulence/scm/perforce'

class Turbulence
  class CommandLineInterface
    TURBULENCE_TEMPLATE_PATH = File.join(File.expand_path(File.dirname(__FILE__)), "..", "..", "template")
    TEMPLATE_FILES = ['turbulence.html',
                      'highcharts.js',
                      'jquery.min.js',
                      'treemap.html'].map do |filename|
      File.join(TURBULENCE_TEMPLATE_PATH, filename)
    end

    attr_reader :exclusion_pattern
    attr_reader :directory
    attr_reader :graph_type

    def initialize(argv, additional_options = {})
      @argv = argv
      @output = additional_options.fetch(:output, STDOUT)

      initialize_config_from_argv
      initialize_collaborators_from_configuration
      initialize_attrs_from_configuration
    end

    def copy_templates_into(directory)
      FileUtils.cp TEMPLATE_FILES, directory
    end

    def generate_bundle
      FileUtils.mkdir_p("turbulence")

      Dir.chdir("turbulence") do
        turb = Turbulence.new(directory, @output, @exclusion_pattern)

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
    attr_reader :argv

    def initialize_config_from_argv
      Turbulence::Calculators::Churn.scm = Scm::Git
      option_parser = OptionParser.new do |opts|
        opts.banner = "Usage: bule [options] [dir]"

        opts.on('--scm p4|git', String, 'scm to use (default: git)') do |s|
          case s
          when "git", "", nil
          when "p4"
            config.scm = Scm::Perforce
          end
        end

        opts.on('--churn-range since..until', String, 'commit range to compute file churn') do |s|
          config.commit_range = s
        end

        opts.on('--churn-mean', 'calculate mean churn instead of cummulative') do
          config.compute_mean = true
        end

        opts.on('--exclude pattern', String, 'exclude files matching pattern') do |pattern|
          config.exclusion_pattern = pattern
        end

        opts.on('--treemap', String, 'output treemap graph instead of scatterplot') do |s|
          config.graph_type = "treemap"
        end


        opts.on_tail("-h", "--help", "Show this message") do
          puts opts
          exit
        end
      end
      option_parser.parse!(argv)

      config.directory = argv.first unless argv.empty?
    end

    def initialize_collaborators_from_configuration
      Turbulence::Calculators::Churn.scm          = config.scm
      Turbulence::Calculators::Churn.commit_range = config.commit_range
      Turbulence::Calculators::Churn.compute_mean = config.compute_mean
    end

    def initialize_attrs_from_configuration
      @exclusion_pattern = config.exclusion_pattern
      @graph_type        = config.graph_type
      @directory         = config.directory
    end
  end
end
