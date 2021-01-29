# This file does not carry out any tests, but resets al the test files to their
# default state. This prevents commiting changes done by the test runs. This
# file runs alphabetically first (hence the aa- prefix), so it guarantees that
# the files will be reset at the start of the test run.

describe "Reset" do
  before (:all) do
    # Reset project structure files
    SpecHelper.reset_testing_conditions
    # Reset dynamic files
    SpecHelper.reset_dyamic_files
  end

  context "Reset all files" do
    it "Reset dynamic files" do
      expect(true).to eq(true)
    end
  end
end
