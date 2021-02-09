class FileHandling
  MANIFEST_FILE = "AndroidManifest.xml"
  GRADLE_FILE = "build.gradle"
  APP_FILE = "Appfile"
  MATCH_FILE = "Matchfile"

  MANIFEST_ATTRIBUTE_REGEX = /package=\"/
  MANIFEST_ATTRIBUTE_LENGTH = 9
  GRADLE_ATTRIBUTE_REGEX = /applicationId \"/
  GRADLE_ATTRIBUTE_LENGTH = 15
  APPFILE_ANDROID_ATTRIBUTE_REGEX = /package_name\(\"/
  APPFILE_ANDROID_ATTRIBUTE_LENGTH = 14
  APPFILE_IOS_ATTRIBUTE_REGEX = /app_identifier\(\"/
  APPFILE_IOS_ATTRIBUTE_LENGTH = 16
  MATCHFILE_ATTRIBUTE_REGEX = /app_identifier\(\[\"/
  MATCHFILE_ATTRIBUTE_LENGTH = 17

  # AndroidManifest

  def self.get_package_name_from_manifest(directory)
    manifest_path = [directory, MANIFEST_FILE].join(File::SEPARATOR)
    package_name = get_package_name_from_file(manifest_path, MANIFEST_ATTRIBUTE_REGEX, MANIFEST_ATTRIBUTE_LENGTH)
    return package_name
  end

  def self.set_package_name_in_manifest(directory, old_package_name, new_package_name)
    manifest_path = [directory, MANIFEST_FILE].join(File::SEPARATOR)
    set_package_name_in_file(manifest_path, old_package_name, new_package_name)
  end

  # gradle.build

  def self.get_package_name_from_gradle(directory)
    gradle_path = [directory, GRADLE_FILE].join(File::SEPARATOR)
    package_name = get_package_name_from_file(gradle_path, GRADLE_ATTRIBUTE_REGEX, GRADLE_ATTRIBUTE_LENGTH)
    return package_name
  end

  def self.set_package_name_in_gradle(directory, old_package_name, new_package_name)
    gradle_path = [directory, GRADLE_FILE].join(File::SEPARATOR)
    set_package_name_in_file(gradle_path, old_package_name, new_package_name)
  end

  # Appfile

  def self.get_package_name_from_appfile(directory, attribute_regex)
    # The attribute is different between iOS and Android (even if it's the same
    # file). Therefore, the attribute regex must be specified when doing
    # opertations for Android and iOS.
    appfile_path = [directory, APP_FILE].join(File::SEPARATOR)
    attribute_length = 0
    if attribute_regex == APPFILE_ANDROID_ATTRIBUTE_REGEX
      attribute_length = APPFILE_ANDROID_ATTRIBUTE_LENGTH
    elsif attribute_regex == APPFILE_IOS_ATTRIBUTE_REGEX
      attribute_length = APPFILE_IOS_ATTRIBUTE_LENGTH
    else
      Fastlane::UI.user_error!("Invalid Appfile attribute regex")
      return -1
    end
    package_name = get_package_name_from_file(appfile_path, attribute_regex, attribute_length)
    return package_name
  end

  def self.set_package_name_in_appfile(directory, old_package_name, new_package_name)
    appfile_path = [directory, APP_FILE].join(File::SEPARATOR)
    set_package_name_in_file(appfile_path, old_package_name, new_package_name)
  end

  def self.update_appfile(appfile_directory, attribute_regex, new_package_name)
    # If the file does not exist, just return.
    if !File.exist?([appfile_directory, APP_FILE].join(File::SEPARATOR))
      return
    end

    appfile_package_name = get_package_name_from_appfile(appfile_directory, attribute_regex)
    if appfile_package_name == -1
      return -1
    elsif appfile_package_name != new_package_name
      set_package_name_in_appfile(appfile_directory, appfile_package_name, new_package_name)
    end
  end

  # Matchfile

  def self.get_package_name_from_matchfile(directory)
    matchfile_path = [directory, MATCH_FILE].join(File::SEPARATOR)
    package_name = get_package_name_from_file(matchfile_path, MATCHFILE_ATTRIBUTE_REGEX, MATCHFILE_ATTRIBUTE_LENGTH)
    return package_name
  end

  def self.set_package_name_in_matchfile(directory, old_package_name, new_package_name)
    matchfile_path = [directory, MATCH_FILE].join(File::SEPARATOR)
    set_package_name_in_file(matchfile_path, old_package_name, new_package_name)
  end

  def self.update_matchfile(matchfile_directory, new_package_name)
    # If the file does not exist, just return.
    if !File.exist?([matchfile_directory, MATCH_FILE].join(File::SEPARATOR))
      return
    end

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

  # Xcode Project file

  def self.get_package_name_from_xcode_project_file(pbxproj_path)
    package_name = get_package_name_from_file(pbxproj_path, /PRODUCT_BUNDLE_IDENTIFIER = /, 28, ";")
    return package_name
  end

  # Info.plist file

  # The process of getting the package name from the Info.plist file differs a
  # bit, in that the attribute spans over two lines. To find the attribute, we
  # need to read the whole file, rather than line by line.
  def self.get_package_name_from_info_plist(info_plist_file)
    # Check file exists
    if !File.exist?(info_plist_file)
      Fastlane::UI.user_error!("The provided path [#{info_plist_file}] does not exist")
      return -1
    end

    package_name = ""

    # Read/write file - https://www.rubyguides.com/2015/05/working-with-files-ruby/#How_to_Read_Files_In_Ruby
    info_plist_contents = File.open(info_plist_file).read
    contents_split = info_plist_contents.split(/<key>CFBundleIdentifier<\/key>\s*<string>/)
    if contents_split.length == 1
      Fastlane::UI.user_error!("No package name attribute could be found in [#{info_plist_file}]")
      return -1
    end

    # On a successful split, we will need the second item in the list, as this
    # will contain the package name.
    contents_with_package_name = contents_split[1]

    # Split again, and get the first item in the list.
    contents_split_again = contents_with_package_name.split("</string>")
    if contents_split_again.length == 1
      Fastlane::UI.user_error!("No package name attribute could be retrieved in [#{info_plist_file}]")
      return -1
    end

    package_name = contents_split_again[0]

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
