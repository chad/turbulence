require 'open3'
class Turbulence
  class ChecksEnvironment
    class << self
      if (RUBY_PLATFORM =~ /mswin|mingw/)
        def git_repo?(directory)
          Dir.chdir directory do
            !(`git status` =~ /Not a git repository/)
          end
        end
      else
        def git_repo?(directory)
          Dir.chdir direcotry do
            Open3.popen3("git status") do |_, _, err, _|
              return !(err.read =~ /Not a git repository/)  
            end
          end
        end
      end
    end
  end
end
