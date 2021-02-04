class GenericHelper
  def self.is_nil_or_whitespace(string)
    return string.nil? || string == "" || string.strip.length == 0
  end

  def self.is_nil_or_empty(array)
    return array.nil? || array.length == 0
  end

  def self.append_directory_separator(directory, separator = File::SEPARATOR)
    # An empty directory or a directory that already ends with the separator
    # does not need any changes done to it.
    if is_nil_or_whitespace(directory) || directory.end_with?(separator)
      return directory
    end

    # Check that the directory is not a file. If it is, just return itself.
    # Note that `File.directory?` alone is not enough (see comment below).
    if File.exist?(directory) && !File.directory?(directory)
      return directory
    end

    # File might not exist. Determine if the path is to a file or a folder.
    # `File.directory?()` returns false if the directory does not exist, even
    # if the path is a valid directory path. This is because files don't need
    # an extension to be a file, so determining whether a non-existent path
    # is a file or directory is impossible. We can use the path's base name
    # and check for an extension (has a "."). If the extension exists, the
    # path points to a file, not a directory. This works for 99% of cases.
    # Ultimately, if `directory` points to a non-existent file without an
    # extension, this method will assume that is a directory.
    if File.basename(directory).include?(".")
      return directory
    end

    return directory + separator
  end
end
