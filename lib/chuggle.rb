require 'flog'
require 'stringio'

class Chuggle
  class Reporter < StringIO
    def average
      Float(string.scan(/^\s+([^:]+).*average$/).flatten.first)
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
      metrics_for(filename)[:churn] = Integer(count)
    end
  end

  def complexity
    flogger = Flog.new
    @ruby_files.each do |filename|
      begin
        flogger.flog filename
        reporter = Reporter.new
        flogger.report(reporter)
        metrics_for(filename)[:complexity] = reporter.average
      rescue SyntaxError => e
        STDERR.puts "#{e}: #{filename}"
        
      rescue Racc::ParseError   => e
        STDERR.puts "#{e}: #{filename}"
        
      rescue RuntimeError => e
        STDERR.puts "#{e}: #{filename}"
      rescue ArgumentError   => e  
        STDERR.puts "#{e}: #{filename}"
        
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
