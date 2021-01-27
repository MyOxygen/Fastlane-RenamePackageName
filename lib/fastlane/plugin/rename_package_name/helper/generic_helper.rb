class GenericHelper
    def self.is_nil_or_whitespace(string)
      return string.nil? || string == "" || !string.strip!.nil?
    end

    def self.is_nil_or_empty(array)
      return array.nil? || array.length == 0
    end
end
