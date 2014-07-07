require 'turbulence/configuration'
require 'turbulence/file_name_mangler'
require 'turbulence/command_line_interface'
require 'turbulence/calculators/churn'
require 'turbulence/calculators/complexity'
require 'turbulence/generators/treemap'
require 'turbulence/generators/scatterplot'

class Turbulence
  CODE_DIRECTORIES = [
    "app/models",
    "app/controllers",
    "app/helpers",
    "app/jobs",
    "app/mailers",
    "app/validators",
    "lib",
  ]
  CALCULATORS = [
    Turbulence::Calculators::Complexity,
    Turbulence::Calculators::Churn,
  ]

  # Make a config instance available to anyone who wants one
  def self.config
    @config ||= Configuration.new
  end

  attr_reader :config
  attr_reader :metrics

  extend Forwardable
  def_delegators :config, *[
    :directory,
    :exclusion_pattern,
    :output,
  ]

  def initialize(config = nil)
    @config  = config || Turbulence.config
    @metrics = {}

    Dir.chdir(directory) do
      calculators.each(&method(:calculate_metrics_with))
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
      set_file_metric(filename, calculator.type, score)
    end

    report "\n"
  end

  def report(this)
    output.print this unless output.nil?
  end

  def set_file_metric(filename, metric, value)
    metrics_for(filename)[metric] = value
  end

  def metrics_for(filename)
    @metrics[filename] ||= {}
  end

  private
  def exclude_files(files)
    if not exclusion_pattern.nil?
      files = files.reject { |f| f =~ Regexp.new(exclusion_pattern) }
    end
    files
  end

  def calculators
    CALCULATORS.map { |calc_class| calc_class.new(config) }
  end
end
