require 'open3'
class Turbulence
  class ChecksEnvironment
    class << self
      def git_repo?(directory)
        Dir.chdir directory do
          !(`git status` =~ /Not a git repository/)
        end
      end
    end
  end
end
