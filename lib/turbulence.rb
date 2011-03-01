require 'turbulence/scatter_plot_generator'
require 'turbulence/command_line_interface'
require 'turbulence/calculators/churn'
require 'turbulence/calculators/complexity'

class Turbulence
  attr_reader :dir
  attr_reader :metrics
  def initialize(dir)
    @dir = dir
    @metrics = {}
    Dir.chdir(dir) do
      churn
      complexity
    end
  end

  def files_of_interest
    files = ["app/models", "app/controllers", "app/helpers", "lib"].map{|base_dir| "#{base_dir}/**/*\.rb"}
    @ruby_files ||= Dir[*files]
  end

  def complexity
    calculate_metrics Turbulence::Calculators::Complexity
  end

  def churn
    calculate_metrics Turbulence::Calculators::Churn
  end

  def calculate_metrics(calculator)
    puts "calculating metric: #{calculator}"
    calculator.for_these_files(files_of_interest) do |filename, score|
      print "."
      set_file_metric(filename, calculator, score)
    end
    puts "\n"
  end

  def set_file_metric(filename, metric, value)
    metrics_for(filename)[metric] = value
  end

  def metrics_for(filename)
    @metrics[filename] ||= {}
  end

end
