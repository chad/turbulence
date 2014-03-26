require 'forwardable'

class Turbulence
  module Calculators
    class Calculator
      def initialize(config = nil)
        @config = config
      end

      attr_writer :config
      def config
        @config ||= Turbulence::Configuration.new
      end
    end
  end
end
