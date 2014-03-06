require 'forwardable'

class Turbulence
  module Calculators
    class Churn
      RUBY_FILE_EXTENSION = ".rb"

      # DIY singleton-like behavior
      class << self
        def instance
          @instance ||= new
        end

        def method_missing(method, *args, &block)
          instance.send(method, *args, &block)
        end
      end
      # /DIY singleton-like behavior

      attr_writer :config
      def config
        @config ||= Turbulence::Configuration.new
      end

      extend Forwardable
      def_delegators :config, *[
        :scm,          :scm=,
        :commit_range, :commit_range=,
        :compute_mean, :compute_mean=,
      ]

      def for_these_files(files)
        changes_by_ruby_file.each do |filename, count|
          yield filename, count if files.include?(filename)
        end
      end

      def changes_by_ruby_file
        ruby_files_changed_in_scm.group_by(&:first).map do |filename, stats|
          churn_for_file(filename,stats)
        end
      end

      def churn_for_file(filename,stats)
        churn = stats[0..-2].map(&:last).inject(0){|running_total, changes| running_total + changes}
        churn = calculate_mean_of_churn(churn, stats.size - 1) if compute_mean
        [filename, churn]
      end

      def calculate_mean_of_churn(churn, sample_size)
        return churn if sample_size < 1
        churn /= sample_size
      end

      def ruby_files_changed_in_scm
        counted_line_changes_by_file_by_commit.select do |filename, _|
          filename.end_with?(RUBY_FILE_EXTENSION) && File.exist?(filename)
        end
      end

      def counted_line_changes_by_file_by_commit
        scm_log_file_lines.map do |line|
          adds, deletes, filename = line.split(/\t/)
          [filename, adds.to_i + deletes.to_i]
        end
      end

      def scm_log_file_lines
        scm_log_command.each_line.reject{|line| line == "\n"}.map(&:chomp)
      end

      def scm_log_command
        scm.log_command(commit_range)
      end
    end
  end
end
