require 'turbulence/calculators/churn'

describe Turbulence::Calculators::Churn do
  let(:calculator) { Turbulence::Calculators::Churn.new(config) }
  let(:config) { Turbulence::Configuration.new }

  before do
    allow(calculator).to receive(:scm_log_command).and_return("")
  end

  describe "::for_these_files" do
    it "yields up the filename and score for each file" do
      files = ["lib/corey.rb", "lib/chad.rb"]
      allow(calculator).to receive(:changes_by_ruby_file).and_return([
        ["lib/corey.rb", 5],
        ["lib/chad.rb", 10]
      ])
      yielded_files = []
      calculator.for_these_files(files) do |filename, score|
        yielded_files << [filename, score]
      end
      expect(yielded_files).to match_array([["lib/corey.rb", 5], ["lib/chad.rb", 10]])
    end

    it "filters the results by the passed-in files" do
      files = ["lib/corey.rb"]
      allow(calculator).to receive(:changes_by_ruby_file).and_return([
        ["lib/corey.rb", 5],
        ["lib/chad.rb", 10]
      ])
      yielded_files = []
      calculator.for_these_files(files) do |filename, score|
        yielded_files << [filename, score]
      end
      expect(yielded_files).to match_array([["lib/corey.rb", 5]])
    end
  end

  describe "::scm_log_file_lines" do
    it "returns just the file lines" do
      allow(calculator).to receive(:scm_log_command).and_return(
        "\n\n\n\n10\t6\tlib/turbulence.rb\n\n\n\n17\t2\tlib/eddies.rb\n"
      )

      expect(calculator.scm_log_file_lines).to match_array([
        "10\t6\tlib/turbulence.rb",
        "17\t2\tlib/eddies.rb"
      ])
    end
  end

  describe "::counted_line_changes_by_file_by_commit" do
    before do
      allow(calculator).to receive(:scm_log_file_lines).and_return([
        "10\t6\tlib/turbulence.rb",
        "17\t2\tlib/eddies.rb"
      ])
    end

    it "sums up the line changes" do
      expect(calculator.counted_line_changes_by_file_by_commit).to match_array([["lib/turbulence.rb", 16], ["lib/eddies.rb", 19]])
    end
  end

  describe "::changes_by_ruby_file" do
    before do
      allow(calculator).to receive(:ruby_files_changed_in_scm).and_return([
        ['lib/eddies.rb', 4],
        ['lib/turbulence.rb', 5],
        ['lib/turbulence.rb', 16],
        ['lib/eddies.rb', 2],
        ['lib/turbulence.rb', 7],
        ['lib/eddies.rb', 19],
        ['lib/eddies.rb', 28]
      ])
    end

    it "groups and sums churns, excluding the last" do
      calculator.compute_mean = false
      expect(calculator.changes_by_ruby_file).to match_array([['lib/eddies.rb', 25], ['lib/turbulence.rb', 21]])
    end

    it "interprets a single entry as zero churn" do
      allow(calculator).to receive(:ruby_files_changed_in_scm).and_return([
        ['lib/eddies.rb', 4],
      ])
      calculator.compute_mean = false
      expect(calculator.changes_by_ruby_file).to match_array([['lib/eddies.rb', 0]])
    end

    it "groups and takes the mean of churns, excluding the last" do
      calculator.compute_mean = true
      expect(calculator.changes_by_ruby_file).to match_array([['lib/eddies.rb', 8], ['lib/turbulence.rb', 10]])
      calculator.compute_mean = false
    end
  end

  describe "::calculate_mean_of_churn" do
    it "handles zero sample size" do
      expect(calculator.calculate_mean_of_churn(8, 0)).to eq 8
    end

    it "returns original churn for sample size = 1" do
      expect(calculator.calculate_mean_of_churn(8, 1)).to eq 8
    end

    it "returns churn divided by sample size" do
      expect(calculator.calculate_mean_of_churn(25, 3)).to eq 8
    end
  end

  context "Full stack tests" do
    context "when one ruby file is given" do
      context "with two log entries for file" do
        before do
          allow(calculator).to receive(:scm_log_command).and_return(
            "\n\n\n\n10\t6\tlib/turbulence.rb\n" +
            "\n\n\n\n11\t7\tlib/turbulence.rb\n"
          )
        end
        it "gives the line change count for the file" do
          yielded_files = []
          calculator.for_these_files(["lib/turbulence.rb"]) do |filename, score|
            yielded_files << [filename, score]
          end
          expect(yielded_files).to match_array([["lib/turbulence.rb", 16]])
        end
        context "with only one log entry for file" do
          before do
            allow(calculator).to receive(:scm_log_command).and_return(
              "\n\n\n\n10\t6\tlib/turbulence.rb\n"
            )
          end
          it "shows zero churn for the file" do
            yielded_files = []
            calculator.for_these_files(["lib/turbulence.rb"]) do |filename, score|
              yielded_files << [filename, score]
            end
            expect(yielded_files).to match_array([["lib/turbulence.rb", 0]])
          end
        end
      end
    end
  end
end
