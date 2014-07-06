class Turbulence
  class ChecksEnvironment
    class << self
      def scm_repo?(directory)
        churn_calculator = Turbulence::Calculators::Churn.new
        churn_calculator.scm.is_repo?(directory)
      end
    end
  end
end
