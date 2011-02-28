require 'fileutils'
require 'launchy'

class Turbulence
  class CommandLineInterface
    TURBULENCE_PATH = File.join(File.expand_path(File.dirname(__FILE__)), "..", "..")

    attr_reader :directory
    def initialize(directory)
      @directory = directory
    end

    def path_to_template(filename)
      File.join(TURBULENCE_PATH, "template", filename)
    end

    def copy_templates_into(directory)
      ['turbulence.html', 'highcharts.js', 'jquery.min.js'].each do |filename|
        FileUtils.cp path_to_template(filename), directory
      end
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
