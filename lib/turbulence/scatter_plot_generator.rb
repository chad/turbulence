require 'json'
class Turbulence
  class ScatterPlotGenerator
    def self.from(metrics_hash)
      new(metrics_hash)
    end
    attr_reader :metrics_hash
    def initialize(metrics_hash)
      @metrics_hash = metrics_hash
    end

    def to_js
      grouped_by_directory = metrics_hash.group_by do |filename, _|
        directories = File.dirname(filename).split("/")
        directories[0..1].join("/")
      end

      directory_series = {}
      grouped_by_directory.each_pair do |directory, metrics_hash|
        data_in_json_format = metrics_hash.map do |filename, metrics|
          {:filename => filename, :x => metrics[Turbulence::Calculators::Churn], :y => metrics[Turbulence::Calculators::Complexity]}
        end.reject do |metrics|
          metrics[:x].nil? || metrics[:y].nil?
        end
        directory_series[directory] = data_in_json_format
      end

      "var directorySeries = #{directory_series.to_json};"
    end
  end
end
