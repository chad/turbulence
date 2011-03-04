require 'turbulence'

describe Turbulence::ScatterPlotGenerator do
  context "with both Metrics" do
    it "generates JavaScript" do
      generator = Turbulence::ScatterPlotGenerator.new(
        "foo.rb" => {
          Turbulence::Calculators::Churn => 1,
          Turbulence::Calculators::Complexity => 2
        }
      )
      generator.to_js.should =~ /var directorySeries/ 
      generator.to_js.should =~ /\"filename\"\:\"foo.rb\"/ 
      generator.to_js.should =~ /\"x\":1/ 
      generator.to_js.should =~ /\"y\":2/ 
    end  
  end

  context "with a missing Metric" do
    it "generates JavaScript" do
      generator = Turbulence::ScatterPlotGenerator.new(
        "foo.rb" => {
          Turbulence::Calculators::Churn => 1
        }
      )
      generator.to_js.should == 'var directorySeries = {};'
    end  
  end

  describe Turbulence::FileNameMangler do
    subject { Turbulence::FileNameMangler.new }
    it "anonymizes a string" do
      subject.mangle_name("chad").should_not == "chad"
    end

    it "maintains standard directory names" do
      subject.mangle_name("/app/controllers/chad.rb").should =~ %r{/app/controllers/1.rb}
    end

    it "honors leading path separators" do
      subject.mangle_name("/a/b/c.rb").should == "/1/2/3.rb"
    end
  end
end

