class Turbulence
  module Generators
    class TreeMap
      attr_reader :metrics_hash, :x_metric, :y_metric

      def initialize(metrics_hash,
                     x_metric = :churn,
                     y_metric = :complexity)
        @x_metric     = x_metric
        @y_metric     = y_metric
        @metrics_hash = metrics_hash
      end

      def generate_results(metrics, cli)
        File.open("treemap_data.js", "w") do |f|
          cli.copy_templates_into(Dir.pwd)
          f.write Turbulence::Generators::TreeMap.from(metrics).build_js
        end
      end

      def build_js
        clean_metrics_from_missing_data

        # Build Highcharts treemap data format
        data = @metrics_hash.map do |filename, metrics|
          churn = metrics[@x_metric] || 0
          complexity = metrics[@y_metric] || 0
          # Ensure minimum value of 1 for churn to avoid zero-size boxes
          churn = 1 if churn.zero?
          {
            name: filename,
            value: churn,
            colorValue: complexity
          }
        end

        "var treemap_data = #{data.to_json};"
      end

      private
      def clean_metrics_from_missing_data
        @metrics_hash.reject! do |filename, metrics|
          metrics[@x_metric].nil? || metrics[@y_metric].nil?
        end
      end

      def self.from(metrics_hash)
        new(metrics_hash)
      end
    end
  end
end
