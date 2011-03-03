require 'turbulence/calculators/churn'

describe Turbulence::Calculators::Churn do
  let(:calculator) { Turbulence::Calculators::Churn }
  before do
    calculator.stub(:scm_log_command) { "" }
  end

  describe "::for_these_files" do
    it "yields up the filename and score for each file" do
      files = ["lib/corey.rb", "lib/chad.rb"]
      calculator.stub(:changes_by_ruby_file) {
        [
          ["lib/corey.rb", 5],
          ["lib/chad.rb", 10]
      ]
      }
      yielded_files = []
      calculator.for_these_files(files) do |filename, score|
        yielded_files << [filename, score]
      end
      yielded_files.should =~ [["lib/corey.rb", 5],
        ["lib/chad.rb",10]]
    end

    it "filters the results by the passed-in files" do
      files = ["lib/corey.rb"]
      calculator.stub(:changes_by_ruby_file) {
        [
          ["lib/corey.rb", 5],
          ["lib/chad.rb", 10]
      ]
      }
      yielded_files = []
      calculator.for_these_files(files) do |filename, score|
        yielded_files << [filename, score]
      end
      yielded_files.should =~ [["lib/corey.rb", 5]]
    end
  end

  describe "::scm_log_file_lines" do
    it "returns just the file lines" do
      calculator.stub(:scm_log_command) do
      "\n\n\n\n10\t6\tlib/turbulence.rb\n\n\n\n17\t2\tlib/eddies.rb\n"
      end

      calculator.scm_log_file_lines.should =~ [
        "10\t6\tlib/turbulence.rb",
        "17\t2\tlib/eddies.rb"
      ]
    end
  end

  describe "::counted_line_changes_by_file_by_commit" do
    before do
      calculator.stub(:scm_log_file_lines) {
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
  
  describe "::changes_by_ruby_file" do
    before do
      calculator.stub(:ruby_files_changed_in_scm) {
        [
          ['lib/eddies.rb', 4],
          ['lib/turbulence.rb', 5],
          ['lib/turbulence.rb', 16],
          ['lib/eddies.rb', 2],
          ['lib/turbulence.rb', 7],
          ['lib/eddies.rb', 19],
          ['lib/eddies.rb', 28]
        ]
      }
    end
    
    it "groups and sums churns, excluding the last" do
      calculator.compute_mean = false
      calculator.changes_by_ruby_file.should =~ [ ['lib/eddies.rb', 25], ['lib/turbulence.rb', 21]]
    end
    
    it "groups and takes the mean of churns, excluding the last" do
      calculator.compute_mean = true
      calculator.changes_by_ruby_file.should =~ [ ['lib/eddies.rb', 8], ['lib/turbulence.rb', 10]]
      calculator.compute_mean = false
    end
  end

  context "Full stack tests" do
    context "when one ruby file is given" do
      context "with two log entries for file" do
        before do
          calculator.stub(:scm_log_command) do
            "\n\n\n\n10\t6\tlib/turbulence.rb\n" +
              "\n\n\n\n11\t7\tlib/turbulence.rb\n"
          end
        end
        it "gives the line change count for the file" do
          yielded_files = []
          calculator.for_these_files(["lib/turbulence.rb"]) do |filename, score|
            yielded_files << [filename, score]
          end
          yielded_files.should =~ [["lib/turbulence.rb", 16]]
        end
        context "with only one log entry for file" do
          before do
            calculator.stub(:scm_log_command) do
              "\n\n\n\n10\t6\tlib/turbulence.rb\n"
            end
          end
          it "shows zero churn for the file" do
            yielded_files = []
            calculator.for_these_files(["lib/turbulence.rb"]) do |filename, score|
              yielded_files << [filename, score]
            end
            yielded_files.should =~ [["lib/turbulence.rb", 0]]
          end
        end
      end
    end
  end
end
