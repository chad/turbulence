require 'rspec'
require 'turbulence'

describe Turbulence do
  it "finds files of interest" do
    turb = Turbulence.new(".")
    turb.exclusion_pattern.should be_nil
    turb.files_of_interest.should include "lib/turbulence.rb"
  end
  
  it "filters out exluded files" do
    turb = Turbulence.new(".", nil, 'turbulence')
    turb.files_of_interest.should_not include "lib/turbulence.rb"
  end
end
