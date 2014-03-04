require 'turbulence/scm/perforce'
require 'rspec/mocks'

describe Turbulence::Scm::Perforce do
  let (:p4_scm) { Turbulence::Scm::Perforce }

  before do
    p4_scm.stub(:p4_list_changes) do
      "Change 62660 on 2005/11/28 by x@client 'CHANGED: adapted to DESCODE '
Change 45616 on 2005/07/12 by x@client 'ADDED: trigger that builds and '
Change 45615 on 2005/07/12 by x@client 'ADDED: for testing purposes '
Change 45614 on 2005/07/12 by x@client 'COSMETIC: updated header '
Change 11250 on 2004/09/17 by x@client 'CHANGED: trigger now also allow'
Change 9250 on 2004/08/20 by x@client 'BUGFIX: bug#1583 (People can so'
Change 5560 on 2004/04/26 by x@client 'ADDED: The \"BRANCHED\" tag.'"
    end

    p4_scm.stub(:p4_describe_change).with("5560") do
      "Change 5560 by x@client on 2004/04/26 17:25:03

        ADDED: The \"BRANCHED\" tag.

Affected files ...

... //admin/scripts/triggers/enforce-submit-comment.py#2 edit
... //admin/scripts/triggers/check-consistency.py#3 edit

Differences ...

==== //admin/scripts/triggers/enforce-submit-comment.py#2 (ktext) ====

add 1 chunks 1 lines
deleted 0 chunks 0 lines
changed 1 chunks 3 / 3 lines

==== //admin/scripts/triggers/check-consistency.py#3 (ktext) ====

add 0 chunks 0 lines
deleted 0 chunks 0 lines
changed 1 chunks 3 / 1 lines"
    end
  end

  describe "::is_repo?" do
    it "returns true if P4CLIENT is set " do
      ENV['P4CLIENT'] = "c-foo.bar"
      Turbulence::Scm::Perforce.is_repo?(".").should == true
    end

    it "returns false if P4CLIENT is empty"  do
      ENV['P4CLIENT'] = ""
      Turbulence::Scm::Perforce.is_repo?(".").should == false
    end

    it "returns false if p4 is not available" do
      ENV['PATH'] = ""
      Turbulence::Scm::Perforce.is_repo?(".").should == false
    end
  end

  describe "::log_command" do
    before do
      p4_scm.stub(:depot_to_local).with("//admin/scripts/triggers/enforce-submit-comment.py")\
        .and_return("triggers/enforce-submit-comments.py")
      p4_scm.stub(:depot_to_local).with("//admin/scripts/triggers/check-consistency.py")\
        .and_return("triggers/check-consistency.py")
      p4_scm.stub(:p4_list_changes) do
        "Change 5560 on 2004/04/26 by x@client 'ADDED: The \"BRANCHED\" tag.'"
      end
    end

    it "takes an optional argument to specify the range" do
      expect{Turbulence::Scm::Perforce.log_command("@1,2")}.to_not raise_error(ArgumentError)
    end

    it "lists insertions/deletions per file and change" do
      Turbulence::Scm::Perforce.log_command().should match(/\d+\t\d+\t[A-z.]*/)
    end
  end

  describe "::changes" do
    it "lists changenumbers from parsing 'p4 changes' output" do
      p4_scm.changes.should =~ %w[62660 45616 45615 45614 11250 9250 5560]
    end
  end

  describe "::files_per_change" do
    before do
      p4_scm.stub(:depot_to_local).with("//admin/scripts/triggers/enforce-submit-comment.py")\
        .and_return("triggers/enforce-submit-comments.py")
      p4_scm.stub(:depot_to_local).with("//admin/scripts/triggers/check-consistency.py")\
        .and_return("triggers/check-consistency.py")
    end

    it "lists files with churn" do
      p4_scm.files_per_change("5560").should  =~ [[4,"triggers/enforce-submit-comments.py"],
        [1,"triggers/check-consistency.py"]]
    end
  end

  describe "::transform_for_output" do
    it "adds a 0 for deletions" do
      p4_scm.transform_for_output([1,"triggers/check-consistency.py"]).should == "1\t0\ttriggers/check-consistency.py\n"
    end
  end

  describe "::depot_to_local" do
    describe "on windows" do
      before do
        p4_scm.stub(:extract_clientfile_from_fstat_of).and_return("D:/Perforce/admin/scripts/triggers/enforce-no-head-change.py")
        FileUtils.stub(:pwd).and_return("D:/Perforce")
      end

      it "converts depot-style paths to local paths using forward slashes" do
        p4_scm.depot_to_local("//admin/scripts/triggers/enforce-no-head-change.py").should \
          == "admin/scripts/triggers/enforce-no-head-change.py"
      end
    end

    describe "on unix" do
      before do
        p4_scm.stub(:extract_clientfile_from_fstat_of).and_return("/home/jhwist/admin/scripts/triggers/enforce-no-head-change.py")
        FileUtils.stub(:pwd).and_return("/home/jhwist")
      end

      it "converts depot-style paths to local paths using forward slashes" do
        p4_scm.depot_to_local("//admin/scripts/triggers/enforce-no-head-change.py").should \
          == "admin/scripts/triggers/enforce-no-head-change.py"
      end
    end
  end

  describe "::extract_clientfile_from_fstat_of" do
    before do
      p4_scm.stub(:p4_fstat) do
        "... depotFile //admin/scripts/triggers/enforce-no-head-change.py
... clientFile /home/jhwist/admin/scripts/triggers/enforce-no-head-change.py
... isMapped
... headAction edit
... headType ktext
... headTime 1214555059
... headRev 5
... headChange 211211
... headModTime 1214555028
... haveRev 5"
      end
    end

    it "uses clientFile field"  do
      p4_scm.extract_clientfile_from_fstat_of("//admin/scripts/triggers/enforce-no-head-change.py").should ==
        "/home/jhwist/admin/scripts/triggers/enforce-no-head-change.py"
    end
  end

  describe "::sum_of_changes" do
    it "sums up changes" do
      output = "add 1 chunks 1 lines\ndeleted 0 chunks 0 lines\nchanged 1 chunks 3 / 3 lines"
      p4_scm.sum_of_changes(output).should == 4
    end

    it "ignores junk" do
      output = "add nothing, change nothing"
      p4_scm.sum_of_changes(output).should == 0
    end
  end
end
