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

describe Turbulence::Calculators::Complexity::Reporter do
  subject { Turbulence::Calculators::Complexity::Reporter.new }
  it "uses the total value from flog" do
    flog_output = <<-FLOG_OUTPUT
     38.7: flog total
     5.5: flog/method average

     9.3: Turbulence#initialize            lib/turbulence.rb:9
     8.7: Turbulence#churn                 lib/turbulence.rb:41
     6.1: Turbulence#complexity            lib/turbulence.rb:26
FLOG_OUTPUT

    subject.stub(:string) { flog_output }

    subject.score.should == 38.7
  end
end
