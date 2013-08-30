require 'turbulence'

describe Turbulence::Generators::ScatterPlot do
  context "with both Metrics" do
    it "generates JavaScript" do
      generator = Turbulence::Generators::ScatterPlot.new(
        "foo.rb" => { Turbulence::Calculators::Churn      => 1,
                      Turbulence::Calculators::Complexity => 2 }
      )

      generator.to_js.should =~ /var directorySeries/
      generator.to_js.should =~ /\"filename\"\:\"foo.rb\"/
      generator.to_js.should =~ /\"x\":1/
      generator.to_js.should =~ /\"y\":2/
    end
  end

  context "with a missing Metric" do
    it "generates JavaScript" do
      generator = Turbulence::Generators::ScatterPlot.new(
        "foo.rb" => { Turbulence::Calculators::Churn => 1 }
      )

      generator.to_js.should == 'var directorySeries = {};'
    end
  end

  describe "#clean_metrics_from_missing_data" do
    let(:spg) {Turbulence::Generators::ScatterPlot.new({})}

    it "removes entries with missing churn" do
      spg.stub(:metrics_hash).and_return("foo.rb" => {
        Turbulence::Calculators::Complexity => 88.3})
        spg.clean_metrics_from_missing_data.should == {}
    end

    it "removes entries with missing complexity" do
      spg.stub(:metrics_hash).and_return("foo.rb" => {
        Turbulence::Calculators::Churn => 1})
        spg.clean_metrics_from_missing_data.should == {}
    end

    it "keeps entries with churn and complexity present" do
      spg.stub(:metrics_hash).and_return("foo.rb" => {
        Turbulence::Calculators::Churn => 1,
        Turbulence::Calculators::Complexity => 88.3})
        spg.clean_metrics_from_missing_data.should_not == {}
    end
  end

  describe "#grouped_by_directory" do
    let(:spg) {Turbulence::Generators::ScatterPlot.new("lib/foo/foo.rb" => {
      Turbulence::Calculators::Churn => 1},
      "lib/bar.rb" => {
      Turbulence::Calculators::Churn => 2} )}

      it "uses \".\" to denote flat hierarchy" do
        spg.stub(:metrics_hash).and_return("foo.rb" => {
          Turbulence::Calculators::Churn => 1
        })
        spg.grouped_by_directory.should == {"." => [["foo.rb", {Turbulence::Calculators::Churn => 1}]]}
      end

      it "takes full path into account" do
        spg.grouped_by_directory.should == {"lib/foo" => [["lib/foo/foo.rb", {Turbulence::Calculators::Churn => 1}]],
          "lib" => [["lib/bar.rb", {Turbulence::Calculators::Churn => 2}]]}
      end
  end

  describe "#file_metrics_for_directory" do
    let(:spg) {Turbulence::Generators::ScatterPlot.new({})}
    it "assigns :filename, :x, :y" do
      spg.file_metrics_for_directory("lib/foo/foo.rb" => {
        Turbulence::Calculators::Churn => 1,
        Turbulence::Calculators::Complexity => 88.2}).should == [{:filename => "lib/foo/foo.rb",
        :x => 1, :y => 88.2}]
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

