require 'json'
require 'erb'
class Chuggle
  class ScatterPlotGenerator
    def self.from(metrics_hash)
      data_in_json_format = metrics_hash.map do |_, metrics|
        [metrics[:churn], metrics[:complexity]]
      end.to_json
      
      ERB.new(template).result(binding)
    end
    
    def self.template
      IO.read(File.join(File.dirname(__FILE__), "../../template/highchart_template.js.erb"))
    end
  end
end