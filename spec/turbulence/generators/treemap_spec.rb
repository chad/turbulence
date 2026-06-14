require 'turbulence'

describe Turbulence::Generators::TreeMap do
  context "with both Metrics" do
    it "generates JavaScript", :aggregate_failures do
      generator = Turbulence::Generators::TreeMap.new(
        "foo.rb" => { :churn      => 1,
                      :complexity => 2 }
      )

      expect(generator.build_js).to match(/var treemap_data/)
      expect(generator.build_js).to match(/\'foo.rb\'/)
    end
  end

  context "with a missing Metric" do
    it "generates JavaScript" do
      generator = Turbulence::Generators::TreeMap.new(
        "foo.rb" => { :churn => 1 }
      )

      expect(generator.build_js).to eq "var treemap_data = [['File', 'Parent', 'Churn (size)', 'Complexity (color)'],\n['Root', null, 0, 0],\n];"
    end
  end
end

