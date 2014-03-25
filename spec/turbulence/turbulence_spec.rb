require 'rspec'
require 'turbulence'

describe Turbulence do
  subject(:turb) { Turbulence.new(config) }

  let(:config) {
    Turbulence::Configuration.new.tap do |config|
      config.output = nil
      config.directory = '.'
    end
  }

  it "finds files of interest" do
    turb.exclusion_pattern.should be_nil
    turb.files_of_interest.should include "lib/turbulence.rb"
  end
  
  it "filters out exluded files" do
    config.exclusion_pattern = 'turbulence'
    turb.files_of_interest.should_not include "lib/turbulence.rb"
  end
end
