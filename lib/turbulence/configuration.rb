class Turbulence
  class Configuration
    attr_accessor *[
      :directory,
      :scm,
      :scm_name,
      :commit_range,
      :compute_mean,
      :exclusion_pattern,
      :graph_type,
      :output,
      :output_dir,
      :no_open,
    ]

    def initialize
      @directory  = Dir.pwd
      @graph_type = 'turbulence'
      @scm_name   = 'Git'
      @output     = STDOUT
      @output_dir = nil
      @no_open    = false
    end

    # TODO: drop attr accessor and ivar once it stops getting set via Churn
    def scm
      @scm || Turbulence::Scm.const_get(scm_name)
    end
  end
end
