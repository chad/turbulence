require 'turbulence/calculators/complexity'

describe Turbulence::Calculators::Complexity do
  let(:calculator) { Turbulence::Calculators::Complexity }
  describe "::for_these_files" do
    it "yields up the filename and score for each file" do
      files = ["lib/corey.rb", "lib/chad.rb"]
      calculator.stub(:score_for_file) { |filename|
        filename.size
      }
      yielded_files = []
      calculator.for_these_files(files) do |filename, score|
        yielded_files << [filename, score]
      end
      yielded_files.should =~ [["lib/corey.rb", 12],
        ["lib/chad.rb",11]]
    end
  end
end

