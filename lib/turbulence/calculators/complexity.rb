require 'stringio'
require 'flog'

class Turbulence
  module Calculators
    class Complexity
      attr_reader :config, :type

      def initialize(config = nil)
        @config = config || Turbulence.config
        @type = :complexity
      end

      def flogger
        @flogger ||= Flog.new(continue: true)
      end

      def for_these_files(files)
        files.each do |filename|
          yield filename, score_for_file(filename)
        end
      end

      def score_for_file(filename)
        flogger.reset
        flogger.flog filename
        flogger.total_score
      end
    end
  end
end
