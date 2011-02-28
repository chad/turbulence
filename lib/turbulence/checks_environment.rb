require 'open3'
class Turbulence
  class ChecksEnvironment
    class << self
      def git_repo?(directory)
        _, err, _ = Open3::capture3("git status")
        !(err =~ /Not a git repository/)
      end
    end
  end
end
