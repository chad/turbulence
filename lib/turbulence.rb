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
      puts "churning"
      churn
      puts "\ncomplexiting"
      complexity
      puts "\n"
    end
  end

  def files_of_interest
    files = ["app/models", "app/controllers", "app/helpers", "lib"].map{|base_dir| "#{base_dir}/**/*\.rb"}
    @ruby_files ||= Dir[*files]
  end

  def complexity
    Turbulence::Calculators::Complexity.for_these_files(files_of_interest) do |filename, score|
      set_file_metric(filename, :complexity, score)
    end
  end

  def set_file_metric(filename, metric, value)
    print "."
    metrics_for(filename)[metric] = value
  end

  def metrics_for(filename)
    @metrics[filename] ||= {}
  end

  def churn
    Turbulence::Calculators::Churn.for_these_files(files_of_interest).each do |count, filename|
      set_file_metric(filename, :churn, Integer(count))
    end
  end
end
