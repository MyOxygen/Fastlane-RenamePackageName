describe GenericHelper do
  private
  INVALID_ARRAYS = [nil, []]
  private
  VALID_ARRAYS = [[nil], [""], [0], [nil, nil], ["", ""], [0, 1]]
  private
  INVALID_STRINGS = [nil, "", "   "]
  private
  VALID_STRINGS = [".", "text", "   text", "text    ", "123 text @@@"]

  context "Is string nil or whitespace" do
    it "Returns true for nil, empty, or white space strings" do
      INVALID_STRINGS.each do |string|
        expect(GenericHelper.is_nil_or_whitespace(string)).to eq(true)
      end
    end

    it "Returns false for valid strings" do
      VALID_STRINGS.each do |string|
        expect(GenericHelper.is_nil_or_whitespace(string)).to eq(false)
      end
    end
  end

  context "Is array nil or empty" do
    it "Returns true for nil or empty arrays" do
      INVALID_ARRAYS.each do |array|
        expect(GenericHelper.is_nil_or_empty(array)).to eq(true)
      end
    end

    it "Returns false for valid arrays" do
      VALID_ARRAYS.each do |array|
        expect(GenericHelper.is_nil_or_empty(array)).to eq(false)
      end
    end
  end

  context "Append directory separator" do
    it "Returns itself if nil/whitespace, is not a directory, or already ends with separator" do
      # Nil or whitespace
      INVALID_STRINGS.each do |string|
        expect(GenericHelper.append_directory_separator(string)).to eq(string)
      end

      # Not a directory
      file_path = "./spec/static_files/bundle.gradle"
      expect(GenericHelper.append_directory_separator(file_path)).to eq(file_path)

      # Already ends with separator
      directory = "./spec/"
      expect(GenericHelper.append_directory_separator(directory)).to eq(directory)
    end

    it "Returns existing directory with separator" do
      directory = "./spec/static_files"
      expected_directory = "./spec/static_files/"
      expect(GenericHelper.append_directory_separator(directory)).to eq(expected_directory)
    end

    it "Returns non-existing directory with separator" do
      directory = "./spec/random_files"
      expected_directory = "./spec/random_files/"
      expect(GenericHelper.append_directory_separator(directory)).to eq(expected_directory)
    end

    it "Returns path for existing file" do
      file_path = "./spec/static_files/MainActivity.kt"
      expected_file_path = "./spec/static_files/MainActivity.kt"
      expect(GenericHelper.append_directory_separator(file_path)).to eq(expected_file_path)
    end

    it "Returns path for existing file without extension" do
      file_path = "./spec/test_files/static_files/Matchfile"
      expected_file_path = "./spec/test_files/static_files/Matchfile"
      expect(GenericHelper.append_directory_separator(file_path)).to eq(expected_file_path)
    end
  end
end
