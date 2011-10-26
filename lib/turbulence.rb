require 'turbulence/scatter_plot_generator'
require 'turbulence/command_line_interface'
require 'turbulence/checks_environment'
require 'turbulence/calculators/churn'
require 'turbulence/calculators/complexity'

class Turbulence
  CODE_DIRECTORIES = ["app/models", "app/controllers", "app/helpers", "app/jobs", "app/mailers", "app/validators", "lib"]
  CALCULATORS = [Turbulence::Calculators::Complexity, Turbulence::Calculators::Churn]

  attr_reader :exclusion_pattern
  attr_reader :metrics
  def initialize(directory, output = nil, exclusion_pattern = nil)
    @output = output
    @metrics = {}
    @exclusion_pattern = exclusion_pattern
    Dir.chdir(directory) do
      CALCULATORS.each(&method(:calculate_metrics_with))
    end
  end

  def files_of_interest
    file_list = CODE_DIRECTORIES.map{|base_dir| "#{base_dir}/**/*\.rb"}
    @ruby_files ||= exclude_files(Dir[*file_list])
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

  private
  def exclude_files(files)
    if not @exclusion_pattern.nil?
      files = files.reject { |f| f =~ Regexp.new(@exclusion_pattern) }
    end
    files
  end
end
