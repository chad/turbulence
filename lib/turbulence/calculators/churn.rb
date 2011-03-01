class Turbulence
  module Calculators
    class Churn
      RB_ENDING = ".rb"

      class << self
        def for_these_files(files)
          changes_by_ruby_file.each do |filename, count|
            yield filename, count if files.include?(filename)
          end
        end

        def changes_by_ruby_file
          ruby_files_changed_in_git.group_by(&:first).map do |filename, stats|
            [filename, stats[0..-2].map(&:last).inject(0){|n, i| n + i}]
          end
        end

        def counted_line_changes_by_file_by_commit
          git_log_file_lines.map do |line|
            adds, deletes, filename = line.split(/\t/)
            [filename, adds.to_i + deletes.to_i]
          end
        end

        def ruby_files_changed_in_git
          counted_line_changes_by_file_by_commit.select do |filename, _|
            filename.end_with?(RB_ENDING) && File.exist?(filename)
          end
        end

        def git_log_file_lines
          git_log_command.each_line.reject{|line| line =~ /^\n$/}.map(&:chomp)
        end

        def git_log_command
          `git log --all -M -C --numstat --format="%n"`
        end
      end
    end
  end
end
