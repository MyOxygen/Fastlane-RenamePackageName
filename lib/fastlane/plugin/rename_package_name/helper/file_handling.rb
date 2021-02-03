class FileHandling
  MANIFEST_FILE = "AndroidManifest.xml"
  GRADLE_FILE = "build.gradle"
  APP_FILE = "AppFile"
  MATCH_FILE = "AppFile"

  # AndroidManifest

  def self.get_package_name_from_manifest(directory)
    manifest_path = directory + MANIFEST_FILE
    package_name = get_package_name_from_file(manifest_path, /package=\"/, 9)
    return package_name
  end

  def self.set_package_name_in_manifest(directory, old_package_name, new_package_name)
    manifest_path = directory + MANIFEST_FILE
    set_package_name_in_file(manifest_path, old_package_name, new_package_name)
  end

  # gradle.build

  def self.get_package_name_from_gradle(directory)
    gradle_path = directory + GRADLE_FILE
    package_name = get_package_name_from_file(gradle_path, /applicationId \"/, 15)
    return package_name
  end

  def self.set_package_name_in_gradle(directory, old_package_name, new_package_name)
    gradle_path = directory + GRADLE_FILE
    set_package_name_in_file(gradle_path, old_package_name, new_package_name)
  end

  # Appfile

  def self.get_package_name_from_appfile(directory, attribute_regex)
    # The attribute is different between iOS and Android (even if it's the same
    # file). Therefore, the attribute regex must be specified when doing
    # opertations for Android and iOS.
    appfile_path = directory + APP_FILE
    package_name = get_package_name_from_file(appfile_path, attribute_regex, 14)
    return package_name
  end

  def self.set_package_name_in_appfile(directory, old_package_name, new_package_name)
    appfile_path = directory + APP_FILE
    set_package_name_in_file(appfile_path, old_package_name, new_package_name)
  end

  def self.update_appfile(appfile_directory, attribute_regex, new_package_name)
    appfile_package_name = get_package_name_from_appfile(appfile_directory, attribute_regex)
    if appfile_package_name != new_package_name
      set_package_name_in_appfile(appfile_directory, appfile_package_name, new_package_name)
    end
  end

  # Matchfile

  def self.get_package_name_from_matchfile(directory)
    matchfile_path = directory + MATCH_FILE
    package_name = get_package_name_from_file(matchfile_path, /app_identifier\(\[\"/, 14)
    return package_name
  end

  def self.set_package_name_in_matchfile(directory, old_package_name, new_package_name)
    matchfile_path = directory + MATCH_FILE
    set_package_name_in_file(matchfile_path, old_package_name, new_package_name)
  end

  def self.update_matchfile(matchfile_directory, new_package_name)
    matchfile_package_name = get_package_name_from_matchfile(matchfile_directory)
    if matchfile_package_name != new_package_name
      set_package_name_in_matchfile(matchfile_directory, matchfile_package_name, new_package_name)
    end
  end

  # Java code file

  def self.get_package_name_from_java_codefile(codefile_path)
    package_name = get_package_name_from_file(codefile_path, /package /, 8, ";")
    return package_name
  end

  # Kotlin code file

  def self.get_package_name_from_kotlin_codefile(codefile_path)
    package_name = get_package_name_from_file(codefile_path, /package /, 8, "\n")
    return package_name
  end

  # Generic

  def self.get_package_name_from_file(file_path, attribute_regex, attribute_regex_length, attribute_end_char = "\"")
    # Check file exists
    if !File.exist?(file_path)
      Fastlane::UI.user_error!("The provided path [#{file_path}] does not exist (current dir: [#{Dir.pwd}]")
      return -1
    end

    package_name = ""

    # Read/write file - https://www.rubyguides.com/2015/05/working-with-files-ruby/#How_to_Read_Files_In_Ruby
    File.foreach(file_path) do |line|
      # RegEx - http://rubylearning.com/satishtalim/ruby_regular_expressions.html
      # String manipulation - https://ruby-doc.org/core-3.0.0/String.html
      index_of_package_attribute = line =~ attribute_regex
      if index_of_package_attribute
        # Retrieve package name
        attribute_removed = line[index_of_package_attribute + attribute_regex_length, 1000] # Use large number for end of string
        partitioned_attribute = attribute_removed.split(attribute_end_char)

        package_name = partitioned_attribute[0]
        break
      end
    end

    return package_name
  end

  def self.set_package_name_in_file(file_path, old_package_name, new_package_name)
    if !File.exist?(file_path)
      Fastlane::UI.user_error!("The provided path [#{file_path}] does not exist (current dir: [#{Dir.pwd}]")
      return -1
    end

    # Read/write file - https://www.rubyguides.com/2015/05/working-with-files-ruby/#How_to_Read_Files_In_Ruby
    file_data = File.read(file_path)
    # Replace package name
    new_file_data = file_data.gsub(old_package_name, new_package_name)
    File.write(file_path, new_file_data)

    # Success
    return 0
  end
end
