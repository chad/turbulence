require 'fileutils'
require 'pathname'

class Turbulence
  module Scm
    class Perforce 
      class << self
        def log_command(commit_range = "")
          full_log = ""
          changes.each do |cn|
            files_per_change(cn).each do |file|
              full_log << transform_for_output(file)
            end
          end
          return full_log
        end

        def is_repo?(directory)
          p4client = ENV['P4CLIENT']
          return !((p4client.nil? or p4client.empty?) and not self.has_p4?)
        end

        def has_p4?
          ENV['PATH'].split(File::PATH_SEPARATOR).any? do |directory|
            File.executable?(File.join(directory, 'p4'))
          end
        end

        def changes(commit_range = "")
          p4_list_changes.each_line.map do |change|
            change.match(/Change (\d+)/)[1]
          end
        end

        def depot_to_local(depot_file)
          abs_path = extract_clientfile_from_fstat_of(depot_file) 
          Pathname.new(abs_path).relative_path_from(Pathname.new(FileUtils.pwd)).to_s
        end

        def extract_clientfile_from_fstat_of(depot_file)
          p4_fstat(depot_file).each_line.select {
            |line| line =~ /clientFile/
          }[0].split(" ")[2].tr("\\","/")
        end

        def files_per_change(change)
          describe_output = p4_describe_change(change).split("\n")
          map = []
          describe_output.each_index do |index|
            if describe_output[index].start_with?("====")
              fn = filename_from_describe(describe_output, index)
              churn = sum_of_changes(describe_output[index .. index + 4].join("\n"))
              map << [churn,fn]
            end
          end
          return map
        end

        def filename_from_describe(output,index)
          depot_to_local(output[index].match(/==== (\/\/.*)#\d+/)[1])
        end

        def transform_for_output(arr)
          "#{arr[0]}\t0\t#{arr[1]}\n"
        end

        def sum_of_changes(p4_describe_output) 
          churn = 0
          p4_describe_output.each_line do |line|
            next unless line =~ /(add|deleted|changed) .* (\d+) lines/
            churn += line.match(/(\d+) lines/)[1].to_i
          end
          return churn
        end

        def p4_list_changes(commit_range = "")
          `p4 changes -s submitted ...#{commit_range}`
        end

        def p4_fstat(depot_file)
          `p4 fstat #{depot_file}`
        end

        def p4_describe_change(change)
          `p4 describe -ds #{change}`
        end
      end
    end
  end
end
