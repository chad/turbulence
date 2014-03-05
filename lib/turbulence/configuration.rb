require 'ostruct'

class Turbulence
  class Configuration
    attr_accessor *[
      :directory,
      :scm,
      :commit_range,
      :compute_mean,
      :exclusion_pattern,
      :graph_type,
    ]

    def initialize
      @directory  = Dir.pwd
      @scm        = Turbulence::Scm::Git
      @graph_type = 'turbulence'
    end
  end
end
