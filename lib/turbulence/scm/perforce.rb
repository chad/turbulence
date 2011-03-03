require 'P4'
#changes = []
#fl = p4.run("filelog","#{ARGV[0]}")
#fl.each do |entry|
#  changes <<  entry["change"]
#end
#changes.flatten!.uniq!.sort!.each do |change|
#  desc = p4.run("describe", "-ds", change)
#  desc.each do |d|
#    puts d.index("depotFile")
#  end
#end
class Turbulence
  module Scm
    class Perforce 
      class << self
        def log_command(commit_range = "", p4 = P4.new)
          ret = p4.connect
          puts "Connect: #{ret}, #{p4.connected?}"
          return ""
        end

        def is_repo?(directory)
          p4client = ENV['P4CLIENT']
          return !(p4client.nil? or p4client.empty?)
        end
      end
    end
  end
end
