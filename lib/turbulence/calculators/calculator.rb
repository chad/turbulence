require 'forwardable'

class Turbulence
  module Calculators
    class Calculator
      extend Forwardable

      # DIY singleton-like behavior
      class << self
        def instance
          @instance ||= new
        end

        def method_missing(method, *args, &block)
          instance.send(method, *args, &block)
        end
      end
      # /DIY singleton-like behavior

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
