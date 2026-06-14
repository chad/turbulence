require 'rspec'
require 'turbulence'

describe Turbulence do
  subject(:turb) { Turbulence.new(config) }

  let(:config) {
    Turbulence::Configuration.new.tap do |config|
      config.directory         = '.'
      config.exclusion_pattern = nil
      config.output            = nil
    end
  }

  it "finds files of interest" do
    expect(turb.files_of_interest).to include "lib/turbulence.rb"
  end

  it "filters out excluded files" do
    config.exclusion_pattern = 'turbulence'
    expect(turb.files_of_interest).not_to include "lib/turbulence.rb"
  end
end
