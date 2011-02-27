require 'flog'
require 'stringio'
require 'grit'

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
      @ruby_files = Dir["**/*\.rb"]
      churn
      complexity
    end
  end

  def churn
    changes_by_ruby_file.each do |count, filename|
      print "."
      metrics_for(filename)[:churn] = Integer(count)
    end
  end

  def complexity
    flogger = Flog.new
    @ruby_files.each do |filename|
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

  private
    def changes_by_ruby_file
      changes_by_file.select do |count, filename|
        filename =~ /\.rb$/ && File.exist?(filename)
      end
    end

    def changes_by_file
      Grit::Repo.new(".").commits.map do |commit| 
        commit.diffs.map(&:b_path)
      end.flatten.group_by{|i| i}.map do |key, value| 
        [key, value.size] 
      end
    end
end
