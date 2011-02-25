require 'json'
class Chuggle
  class ScatterPlotGenerator
    def self.from(metrics_hash)
      data_in_json_format = metrics_hash.map do |filename, metrics|
        {:filename => filename, :x => metrics[:churn], :y => metrics[:complexity]}
      end.reject do |metrics|
          metrics[:x].nil? || metrics[:y].nil?
      end.to_json
      "var chuggleGraphData = #{data_in_json_format};"
    end
  end
end
