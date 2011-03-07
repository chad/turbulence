require 'fileutils'
require 'launchy'
require 'optparse'
require 'turbulence/scm/git'
require 'turbulence/scm/perforce'

class Turbulence
  class CommandLineInterface
    TURBULENCE_TEMPLATE_PATH = File.join(File.expand_path(File.dirname(__FILE__)), "..", "..", "template")
    TEMPLATE_FILES = ['turbulence.html', 'highcharts.js', 'jquery.min.js'].map { |filename|
      File.join(TURBULENCE_TEMPLATE_PATH, filename)
    }

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
    private :copy_templates_into

    def generate_bundle
      FileUtils.mkdir_p("turbulence")
      Dir.chdir("turbulence") do
        copy_templates_into(Dir.pwd)
        File.open("cc.js", "w") do |f|
          f.write Turbulence::ScatterPlotGenerator.from(Turbulence.new(directory,STDOUT).metrics).to_js
        end
      end
    end

    def open_bundle
      Launchy.open("file://#{directory}/turbulence/turbulence.html")
    end
  end
end
