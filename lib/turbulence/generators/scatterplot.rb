class Turbulence
  module Generators
    class ScatterPlot
      attr_reader :metrics_hash, :x_metric, :y_metric

      def initialize(metrics_hash, x_metric = Turbulence::Calculators::Churn, y_metric = Turbulence::Calculators::Complexity)
        @x_metric     = x_metric
        @y_metric     = y_metric
        @metrics_hash = metrics_hash
      end

      def self.from(metrics_hash)
        new(metrics_hash)
      end

      def mangle
        mangler = FileNameMangler.new
        mangled = {}
        metrics_hash.each_pair { |filename, metrics| mangled[mangler.mangle_name(filename)] = metrics}
        @metrics_hash = mangled
      end

      def to_js
        clean_metrics_from_missing_data
        directory_series = {}

        grouped_by_directory.each_pair do |directory, metrics_hash|
          directory_series[directory] = file_metrics_for_directory(metrics_hash)
        end

        "var directorySeries = #{directory_series.to_json};"
      end

      def clean_metrics_from_missing_data
        metrics_hash.reject! do |filename, metrics|
          metrics[x_metric].nil? || metrics[y_metric].nil?
        end
      end

      def grouped_by_directory
        metrics_hash.group_by do |filename, _|
          directories = File.dirname(filename).split("/")
          directories[0..1].join("/")
        end
      end

      def file_metrics_for_directory(metrics_hash)
        metrics_hash.map do |filename, metrics|
          {:filename => filename, :x => metrics[x_metric], :y => metrics[y_metric]}
        end
      end

      def generate_results(metrics, ci)
        File.open("cc.js", "w") do |f|
          ci.copy_templates_into(Dir.pwd)
          f.write Turbulence::Generators::ScatterPlot.from(metrics).to_js
        end
      end

      private
      # def copy_templates_into(directory)
      #   FileUtils.cp TEMPLATE_FILES, directory
      # end
    end
  end
end
