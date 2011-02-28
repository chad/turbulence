require 'stringio'
require 'flog'
class Turbulence
  module Calculators
    class Complexity
      class << self
        def flogger
          @flogger ||= Flog.new
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
        rescue SyntaxError, Racc::ParseError
          STDERR.puts "\nError flogging: #{filename}\n"
        end
      end

      class Reporter < ::StringIO
        def score
          Float(string.scan(/^\s+([^:]+).*total$/).flatten.first)
        end
      end
    end
  end
end
