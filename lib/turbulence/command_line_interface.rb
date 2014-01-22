require 'fileutils'
require 'launchy'
require 'optparse'
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
    def initialize(argv)
      Turbulence::Calculators::Churn.scm = Scm::Git
      OptionParser.new do |opts|
        opts.banner = "Usage: bule [options] [dir]"

        opts.on('--scm p4|git', String, 'scm to use (default: git)') do |s|
          case s
          when "git", "", nil
          when "p4"
            Turbulence::Calculators::Churn.scm = Scm::Perforce
          end
        end

        opts.on('--churn-range since..until', String, 'commit range to compute file churn') do |s|
          Turbulence::Calculators::Churn.commit_range = s
        end

        opts.on('--churn-mean', 'calculate mean churn instead of cummulative') do
          Turbulence::Calculators::Churn.compute_mean = true
        end

        opts.on('--exclude pattern', String, 'exclude files matching pattern') do |pattern|
          @exclusion_pattern = pattern
        end

        opts.on('--treemap', String, 'output treemap graph instead of scatterplot') do |s|
          @graph_type = "treemap"
        end


        opts.on_tail("-h", "--help", "Show this message") do
          puts opts
          exit
        end
      end.parse!(argv)

      @directory = argv.first || Dir.pwd
    end

    def copy_templates_into(directory)
      FileUtils.cp TEMPLATE_FILES, directory
    end

    def generate_bundle
      FileUtils.mkdir_p("turbulence")

      Dir.chdir("turbulence") do
        turb = Turbulence.new(directory,STDOUT, @exclusion_pattern)

        generator = case @graph_type
        when "treemap"
          Turbulence::Generators::TreeMap.new({})
        else
          Turbulence::Generators::ScatterPlot.new({})
        end

        generator.generate_results(turb.metrics, self)
      end
    end

    def open_bundle
      case @graph_type
      when "treemap"
        Launchy.open("file:///#{directory}/turbulence/treemap.html")
      else
        Launchy.open("file:///#{directory}/turbulence/turbulence.html")
      end
    end
  end
end
