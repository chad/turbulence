require 'json'

class Turbulence
  class FileNameMangler
    def initialize
      @current_id = 0
      @segment_map = { "" => "", "app" => "app", "controllers" => "controllers", "helpers" => "helpers", "lib" => "lib" }
    end

    def transform(segment)
      @segment_map[segment] ||= (@current_id += 1)
    end

    def mangle_name(filename)
      filename.split('/').map {|seg|transform(seg)}.join('/') + ".rb"
    end
  end

  class ScatterPlotGenerator
    def self.from(metrics_hash)
      new(metrics_hash)
    end
    attr_reader :metrics_hash, :x_metric, :y_metric
    def initialize(metrics_hash, x_metric = Turbulence::Calculators::Churn, y_metric = Turbulence::Calculators::Complexity)
      @x_metric = x_metric
      @y_metric = y_metric
      @metrics_hash = metrics_hash
    end

    def mangle
      mangler = FileNameMangler.new
      mangled = {}
      metrics_hash.each_pair { |filename, metrics| mangled[mangler.mangle_name(filename)] = metrics}
      @metrics_hash = mangled
    end

    def to_js
      metrics_hash.reject! do |filename, metrics|
        metrics[x_metric].nil? || metrics[y_metric].nil?
      end
      
      grouped_by_directory = metrics_hash.group_by do |filename, _|
        directories = File.dirname(filename).split("/")
        directories[0..1].join("/")
      end

      directory_series = {}
      grouped_by_directory.each_pair do |directory, metrics_hash|
        directory_series[directory] = metrics_hash.map do |filename, metrics|
          {:filename => filename, :x => metrics[x_metric], :y => metrics[y_metric]}
        end
      end

      "var directorySeries = #{directory_series.to_json};"
    end
  end
end
