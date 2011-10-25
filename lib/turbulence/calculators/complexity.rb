require 'stringio'
require 'flog'

class Ruby19Parser < RubyParser
  def process(ruby, file)
    ruby.gsub!(/(\w+):\s+/, '"\1" =>')
    super(ruby, file)
  end
end

class Flog19 < Flog
  def initialize option = {}
    super(option)
    @parser = Ruby19Parser.new
  end
end

class Turbulence
  module Calculators
    class Complexity
      class << self
        def flogger
          @flogger ||= Flog19.new(:continue => true)
        end
        def for_these_files(files)
          files.each do |filename|
            yield filename, score_for_file(filename)
          end
        end

        def score_for_file(filename)
          flogger.flog filename
          reporter = Reporter.new
          flogger.report(reporter)
          reporter.score
        end
      end

      class Reporter < ::StringIO
        SCORE_LINE_DETECTOR = /^\s+([^:]+).*flog total$/
        def score
          Float(string.scan(SCORE_LINE_DETECTOR).flatten.first)
        end
      end
    end
  end
end
