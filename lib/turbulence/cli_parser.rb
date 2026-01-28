class Turbulence
  class CommandLineInterface
    # I Update a Turbulence::Configuration instance to match the user's
    # expectations (as expressed in ARGV)
    module ConfigParser
      def self.parse_argv_into_config(argv, config)
        OptionParser.new do |opts|
          opts.banner = "Usage: bule [options] [dir]"

          # Use `accept` for type validation and conversion
          opts.accept(Symbol) do |s|
            s.to_sym if %w[git p4].include?(s)
          end

          opts.on('--scm=SCM', Symbol, 'SCM to use: git or p4 (default: git)') do |s|
            config.scm_name = s == :p4 ? 'Perforce' : 'Git'
          end

          opts.on('--churn-range=RANGE', String, 'Commit range to compute file churn') do |s|
            config.commit_range = s
          end

          opts.on('--churn-mean', 'Calculate mean churn instead of cumulative') do
            config.compute_mean = true
          end

          opts.on('--exclude=PATTERN', String, 'Exclude files matching pattern') do |pattern|
            config.exclusion_pattern = pattern
          end

          opts.on('--treemap', 'Output treemap graph instead of scatterplot') do
            config.graph_type = "treemap"
          end

          opts.on('--[no-]open', 'Open the generated bundle (default: open)') do |v|
            config.open_bundle = v
          end

          opts.on_tail('-h', '--help', 'Show this message') do
            puts opts
            exit
          end

        end.parse!(argv)

        # Set directory if provided
        config.directory = argv.first if argv.any?
      end
    end
  end
end
