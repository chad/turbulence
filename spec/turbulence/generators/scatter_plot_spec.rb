require 'turbulence'

describe Turbulence::Generators::ScatterPlot do
  context "with both Metrics" do
    it "generates JavaScript", :aggregate_failures do
      generator = Turbulence::Generators::ScatterPlot.new(
        "foo.rb" => { :churn      => 1,
                      :complexity => 2 }
      )

      expect(generator.to_js).to match(/var directorySeries/)
      expect(generator.to_js).to match(/\"filename\"\:\"foo.rb\"/)
      expect(generator.to_js).to match(/\"x\":1/)
      expect(generator.to_js).to match(/\"y\":2/)
    end
  end

  context "with a missing Metric" do
    it "generates JavaScript" do
      generator = Turbulence::Generators::ScatterPlot.new(
        "foo.rb" => { :churn => 1 }
      )

      expect(generator.to_js).to eq 'var directorySeries = {};'
    end
  end

  describe "#clean_metrics_from_missing_data" do
    let(:spg) { Turbulence::Generators::ScatterPlot.new({}) }

    it "removes entries with missing churn" do
      allow(spg).to receive(:metrics_hash).and_return("foo.rb" => { :complexity => 88.3 })
      expect(spg.clean_metrics_from_missing_data).to eq({})
    end

    it "removes entries with missing complexity" do
      allow(spg).to receive(:metrics_hash).and_return("foo.rb" => { :churn => 1 })
      expect(spg.clean_metrics_from_missing_data).to eq({})
    end

    it "keeps entries with churn and complexity present" do
      allow(spg).to receive(:metrics_hash).and_return("foo.rb" => {
        :churn      => 1,
        :complexity => 88.3,
      })

      expect(spg.clean_metrics_from_missing_data).not_to eq({})
    end
  end

  describe "#grouped_by_directory" do
    let(:spg) {
      Turbulence::Generators::ScatterPlot.new(
        "lib/foo/foo.rb" => { :churn => 1 },
        "lib/bar.rb" => { :churn => 2 }
      )
    }

    it "uses \".\" to denote flat hierarchy" do
      allow(spg).to receive(:metrics_hash).and_return("foo.rb" => { :churn => 1 })
      expect(spg.grouped_by_directory).to eq({ "." => [["foo.rb", { :churn => 1 }]] })
    end

    it "takes full path into account" do
      expect(spg.grouped_by_directory).to eq({
        "lib/foo" => [["lib/foo/foo.rb", { :churn => 1 }]],
        "lib" => [["lib/bar.rb", { :churn => 2 }]]
      })
    end
  end

  describe "#file_metrics_for_directory" do
    let(:spg) { Turbulence::Generators::ScatterPlot.new({}) }

    it "assigns :filename, :x, :y" do
      result = spg.file_metrics_for_directory("lib/foo/foo.rb" => {
        :churn      => 1,
        :complexity => 88.2,
      })
      expect(result).to eq [{ :filename => "lib/foo/foo.rb", :x => 1, :y => 88.2 }]
    end
  end

  describe Turbulence::FileNameMangler do
    subject { Turbulence::FileNameMangler.new }

    it "anonymizes a string" do
      expect(subject.mangle_name("chad")).not_to eq "chad"
    end

    it "maintains standard directory names" do
      expect(subject.mangle_name("/app/controllers/chad.rb")).to match(%r{/app/controllers/1.rb})
    end

    it "honors leading path separators" do
      expect(subject.mangle_name("/a/b/c.rb")).to eq "/1/2/3.rb"
    end
  end
end

