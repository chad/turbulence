class Turbulence
  module Scm
    class Git
      class << self
        def log_command(commit_range)
          `git log --all -M -C --numstat --format="%n" #{commit_range}`
        end

        def is_repo?(directory)
          FileUtils.cd(directory) {
            return !(`git status 2>&1` =~ /Not a git repository/)
          }
        end
      end
    end
  end
end
