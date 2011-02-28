require 'flog'
require 'stringio'
require 'turbulence/scatter_plot_generator'
require 'turbulence/command_line_interface'
require 'turbulence/calculators/churn'

class Turbulence
  class Reporter < StringIO
    def average
      Float(string.scan(/^\s+([^:]+).*total$/).flatten.first)
    end
  end

  attr_reader :dir
  attr_reader :metrics
  def initialize(dir)
    @dir = dir
    @metrics = {}
    Dir.chdir(dir) do
      churn
      complexity
    end
  end

  def ruby_files
    files = ["app/models", "app/controllers", "app/helpers", "lib"].map{|base_dir| "#{base_dir}/**/*\.rb"}
    @ruby_files ||= Dir[*files]
  end

  def complexity
    flogger = Flog.new
    ruby_files.each do |filename|
      print "."

      begin
        flogger.flog filename
        reporter = Reporter.new
        flogger.report(reporter)
        metrics_for(filename)[:complexity] = reporter.average
      rescue SyntaxError, Racc::ParseError => e
        puts "\nError flogging: #{filename}\n"
      end
    end
  end

  def metrics_for(filename)
    @metrics[filename] ||= {}
  end

  def churn
    files = Turbulence::Calculators::Churn.for_these_files([]).select { |_, filename| ruby_files.include?(filename) }
    files.each do |count, filename|
      print "."
      metrics_for(filename)[:churn] = Integer(count)
    end
  end
end
