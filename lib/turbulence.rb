require 'turbulence/scatter_plot_generator'
require 'turbulence/command_line_interface'
require 'turbulence/checks_environment'
require 'turbulence/calculators/churn'
require 'turbulence/calculators/complexity'

class Turbulence
  CODE_DIRECTORIES = ["app/models", "app/controllers", "app/helpers", "lib"]
  CALCULATORS = [Turbulence::Calculators::Complexity, Turbulence::Calculators::Churn]

  attr_reader :metrics
  def initialize(directory, output = nil)
    @output = output
    @metrics = {}
    Dir.chdir(directory) do
      CALCULATORS.each(&method(:calculate_metrics_with))
    end
  end

  def files_of_interest
    file_list = CODE_DIRECTORIES.map{|base_dir| "#{base_dir}/**/*\.rb"}
    @ruby_files ||= Dir[*file_list]
  end

  def calculate_metrics_with(calculator)
    report "calculating metric: #{calculator}\n"
    calculator.for_these_files(files_of_interest) do |filename, score|
      report "."
      set_file_metric(filename, calculator, score)
    end
    report "\n"
  end

  def report(this)
    @output.print this unless @output.nil?
  end

  def set_file_metric(filename, metric, value)
    metrics_for(filename)[metric] = value
  end

  def metrics_for(filename)
    @metrics[filename] ||= {}
  end

end
