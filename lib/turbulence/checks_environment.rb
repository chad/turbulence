class Turbulence
  class ChecksEnvironment
    class << self
      def scm_repo?(directory)
        Turbulence::Calculators::Churn.scm.is_repo?(directory)
      end
    end
  end
end
