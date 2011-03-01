require 'turbulence'

describe Turbulence::ScatterPlotGenerator do
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

