class Turbulence
  module Scm
    class Perforce 
      class << self
        def log_command(commit_range)
        end

        def is_repo?(directory)
          p4client = ENV['P4CLIENT']
          return !(p4client.nil? or p4client.empty?)
        end
      end
    end
  end
end
