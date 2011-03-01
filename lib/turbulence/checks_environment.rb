require 'open3'
class Turbulence
  class ChecksEnvironment
    class << self
      def git_repo?(directory)
        Open3.popen3("git status") do |_, _, err, _|
          return !(err.read =~ /Not a git repository/)  
        end
      end
    end
  end
end
