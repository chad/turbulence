class Turbulence
  class CommandLineInterface
    module ConfigParser
      def self.parse_argv_into_config(argv, config)
        option_parser = OptionParser.new do |opts|
          opts.banner = "Usage: bule [options] [dir]"

          opts.on('--scm p4|git', String, 'scm to use (default: git)') do |s|
            case s
            when "git", "", nil
            when "p4"
              config.scm_name = 'Perforce'
            end
          end

          opts.on('--churn-range since..until', String, 'commit range to compute file churn') do |s|
            config.commit_range = s
          end

          opts.on('--churn-mean', 'calculate mean churn instead of cummulative') do
            config.compute_mean = true
          end

          opts.on('--exclude pattern', String, 'exclude files matching pattern') do |pattern|
            config.exclusion_pattern = pattern
          end

          opts.on('--treemap', String, 'output treemap graph instead of scatterplot') do |s|
            config.graph_type = "treemap"
          end


          opts.on_tail("-h", "--help", "Show this message") do
            puts opts
            exit
          end
        end
        option_parser.parse!(argv)

        config.directory = argv.first unless argv.empty?
      end
    end
  end
end
