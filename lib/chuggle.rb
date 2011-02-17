require 'flog'
require 'stringio'

class Chuggle
  attr_reader :dir
  def initialize(dir)
    @dir = dir
    Dir.chdir(dir) do
      @ruby_files = Dir["**/*\.rb"]
    end
  end

  def churn
    Dir.chdir(dir) do
      raw = `git log --all -M -C --name-only | grep -E '^(app|lib)/' | sort | uniq -c | sort`.split(/\n/).map(&:split)
      raw.select do |count, filename|
        filename =~ /rb$/
      end.map do |count, filename|
        [Integer(count), filename]
      end
    end
  end

  def flog
    Dir.chdir(dir) do
      flogger = Flog.new
      @ruby_files.map do |filename|
        p filename
        flogger.flog filename
        report = StringIO.new
        flogger.report(report)
        report.to_s.scan(/^.+average$/).first
      end 
    end
  end
end
