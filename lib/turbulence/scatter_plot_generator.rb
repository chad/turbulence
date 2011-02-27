require 'json'
class Turbulence
  class ScatterPlotGenerator
    def self.from(metrics_hash)

      data_in_json_format = metrics_hash.map do |filename, metrics|
        {:filename => filename, :x => metrics[:churn], :y => metrics[:complexity]}
      end.reject do |metrics|
          metrics[:x].nil? || metrics[:y].nil?
      end.to_json
      series = ["var turbulenceGraphData = #{data_in_json_format};"]

      grouped_by_directory = metrics_hash.group_by do |filename, _|
        directories = File.dirname(filename).split("/")
        directories[0..1].join("/")
      end

      directory_series = {}
      grouped_by_directory.each_pair do |directory, metrics_hash|
        data_in_json_format = metrics_hash.map do |filename, metrics|
          {:filename => filename, :x => metrics[:churn], :y => metrics[:complexity]}
        end.reject do |metrics|
            metrics[:x].nil? || metrics[:y].nil?
        end
        directory_series[directory] = data_in_json_format
      end

      series << "var directorySeries = #{directory_series.to_json};"

      series.join("\n")
    end
  end
end
