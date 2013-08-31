class Turbulence
  module Generators
    class TreeMap
      attr_reader :metrics_hash, :x_metric, :y_metric

      def initialize(metrics_hash,
                     x_metric = Turbulence::Calculators::Churn,
                     y_metric = Turbulence::Calculators::Complexity)
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

        output = "var treemap_data = [['File', 'Parent', 'Churn (size)', 'Complexity (color)'],\n"
        output << "['Root', null, 0, 0],\n"

        @metrics_hash.each do |file|
          output << "['#{file[0]}', 'Root', #{file[1][@x_metric]}, #{file[1][@y_metric]}],\n"
        end

        output << "];"

        output
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
