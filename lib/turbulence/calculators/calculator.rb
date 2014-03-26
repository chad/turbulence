class Turbulence
  module Calculators
    class Calculator
      attr_reader :config
      def initialize(config = nil)
        @config = config || Turbulence.config
      end
    end
  end
end
