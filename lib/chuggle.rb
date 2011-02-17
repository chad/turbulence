require 'flog'
require 'stringio'

class Chuggle
  attr_reader :dir
  attr_reader :metrics
  def initialize(dir)
    @dir = dir
    @metrics = {}
    Dir.chdir(dir) do
      @ruby_files = Dir["**/*\.rb"]
      churn
      flog
    end
  end

  def churn
    # borrowed from @coreyhaines
    raw = `git log --all -M -C --name-only| sort | uniq -c | sort`.split(/\n/).map(&:split)
    raw.select do |count, filename|
      filename =~ /\.rb$/
    end.each do |count, filename|
      metrics_for(filename)[:churn] = Integer(count)
    end
  end

  def flog
    flogger = Flog.new
    @ruby_files.each do |filename|
      flogger.flog filename
      report = StringIO.new
      flogger.report(report)
      score = Float(report.string.scan(/^\s+([^:]+).*average$/).flatten.first)
      metrics_for(filename)[:flog] = score
    end 
  end
  
  def metrics_for(filename)
    @metrics[filename] ||= {}
  end
end
