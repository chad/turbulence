require 'turbulence/calculators/churn'

describe Turbulence::Calculators::Churn do
  let(:calculator) { Turbulence::Calculators::Churn }
  before do
    calculator.stub(:git_log_command) { "" }
  end

  it "filters the results by the passed-in files" do
    calculator.stub(:changes_by_ruby_file) {
      [
        [5, "lib/corey.rb"],
        [10, "lib/chad.rb"]
    ]
    }

    calculator.for_these_files(["lib/corey.rb"]).should == [[5,"lib/corey.rb"]]
  end

  describe "::git_log_file_lines" do
    it "returns just the file lines" do
      calculator.stub(:git_log_command) do
      "\n\n\n\n10\t6\tlib/turbulence.rb\n\n\n\n17\t2\tlib/eddies.rb\n"
      end

      calculator.git_log_file_lines.should =~ [
        "10\t6\tlib/turbulence.rb",
        "17\t2\tlib/eddies.rb"
      ]
    end
  end

  describe "::counted_line_changes_by_file_by_commit" do
    before do
      calculator.stub(:git_log_file_lines) {
        [
          "10\t6\tlib/turbulence.rb",
          "17\t2\tlib/eddies.rb"
        ]
      }
    end

    it "sums up the line changes" do
      calculator.counted_line_changes_by_file_by_commit.should =~ [["lib/turbulence.rb", 16], ["lib/eddies.rb", 19]]
    end
  end

  context "when one ruby file is given" do
    before do
      calculator.stub(:git_log_command) do
        "\n\n\n\n10\t6\tlib/turbulence.rb\n" +
        "\n\n\n\n11\t7\tlib/turbulence.rb\n"
      end
    end
    context "with only one log entry" do
      before do
        calculator.stub(:git_log_command) do
        "\n\n\n\n10\t6\tlib/turbulence.rb\n"
        end
      end
      it "shows zero churn for the file" do
        calculator.for_these_files(["lib/turbulence.rb"]).first.first.should == 0
      end
    end
    it "gives the line change count for the file" do
      calculator.for_these_files(["lib/turbulence.rb"]).first.first.should == 16
    end
    it "includes an entry for that file" do
      calculator.for_these_files(["lib/turbulence.rb"]).first.last.should == "lib/turbulence.rb"
    end
  end
end
