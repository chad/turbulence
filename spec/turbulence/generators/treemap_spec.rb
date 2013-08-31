require 'turbulence'

describe Turbulence::Generators::TreeMap do
  context "with both Metrics" do
    it "generates JavaScript" do
      generator = Turbulence::Generators::TreeMap.new(
        "foo.rb" => { Turbulence::Calculators::Churn      => 1,
                      Turbulence::Calculators::Complexity => 2 }
      )

      generator.build_js.should =~ /var treemap_data/
      generator.build_js.should =~ /\'foo.rb\'/
    end
  end

  context "with a missing Metric" do
    it "generates JavaScript" do
      generator = Turbulence::Generators::TreeMap.new(
        "foo.rb" => { Turbulence::Calculators::Churn => 1 }
      )

      generator.build_js.should == "var treemap_data = [['File', 'Parent', 'Churn (size)', 'Complexity (color)'],\n['Root', null, 0, 0],\n];"
    end
  end
end

