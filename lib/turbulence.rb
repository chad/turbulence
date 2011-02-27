require 'flog'
require 'stringio'

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

  def churn
    files = changes_by_ruby_file.select { |_, filename| ruby_files.include?(filename) }
    files.each do |count, filename|
      print "."
      metrics_for(filename)[:churn] = Integer(count)
    end
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

  private
    def changes_by_ruby_file
      changes_by_file.select do |count, filename|
        filename =~ /\.rb$/ && File.exist?(filename)
      end
    end

    def changes_by_file
      # borrowed from @coreyhaines
      `git log --all -M -C --name-only| sort | uniq -c | sort`.split(/\n/).map(&:split)
    end
end
