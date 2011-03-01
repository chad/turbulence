require 'fileutils'
require 'launchy'

class Turbulence
  class CommandLineInterface
    TURBULENCE_TEMPLATE_PATH = File.join(File.absolute_path(File.dirname(__FILE__)), "..", "..", "template")
    TEMPLATE_FILES = ['turbulence.html', 'highcharts.js', 'jquery.min.js'].map { |filename|
      File.join(TURBULENCE_TEMPLATE_PATH, filename)
    }

    attr_reader :directory
    def initialize(argv)
      @directory = argv.first
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
          f.write Turbulence::ScatterPlotGenerator.from(Turbulence.new(directory).metrics).to_js
        end
      end
    end

    def open_bundle
      Launchy.open("file://#{directory}/turbulence/turbulence.html")
    end
  end
end
