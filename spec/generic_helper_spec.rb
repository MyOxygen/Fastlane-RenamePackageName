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
end
