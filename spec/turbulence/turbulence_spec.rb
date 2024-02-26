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
    turb.files_of_interest.should include "lib/turbulence.rb"
  end
  
  it "filters out excluded files" do
    config.exclusion_pattern = 'turbulence'
    turb.files_of_interest.should_not include "lib/turbulence.rb"
  end
end
