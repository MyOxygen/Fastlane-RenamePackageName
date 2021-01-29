require_relative "./file_handling.rb"
require_relative "./generic_helper.rb"

class AndroidHelper
  def self.rename_package_names(project_home_path, new_package_name, profiles, language = "java")
    # First check the parameters
    if GenericHelper.is_nil_or_whitespace(project_home_path)
      Fastlane::UI.user_error!("Invalid project home path: [#{project_home_path}]")
      return -1
    end

    path = project_home_path
    if !path.end_with?("/")
      path += "/"
    end

    gradle_directory = path + "app/"
    # fastlane_directory = path + "fastlane/"
    source_directory = gradle_directory + "src/"

    if GenericHelper.is_nil_or_whitespace(new_package_name)
      Fastlane::UI.user_error!("Invalid package name: [#{new_package_name}]")
      return -1
    end

    if GenericHelper.is_nil_or_empty(profiles)
      Fastlane::UI.user_error!("Invalid profiles")
      return -1
    end

    if GenericHelper.is_nil_or_whitespace(language) || !(language.casecmp?("java") || language.casecmp?("kotlin"))
      Fastlane::UI.user_error!("Invalid programming language: [#{language}]")
      return -1
    end

    # 1. Determine if we need to change the package name throughout the
    #    Android project.
    old_package_name = FileHandling.get_package_name_from_manifest(source_directory + profiles[0] + "/")
    if old_package_name == -1
      return -1
    end
    status = update_manifests(source_directory, profiles, new_package_name)
    if status == -1
      return -1
    end

    # 2. Check if we need to move the necessary files into the new package-
    #    name-driven folder structure, AND that the package reference is
    #    updated in both Java and Kotlin code files.
    # TODO: This doesn't seem to move the files if the new directory exists. Why?
    move_code_files(source_directory, language, old_package_name, new_package_name)

    # 3. Check if the package name needs changing in the app/build.gradle file.
    status = update_gradle(gradle_directory, new_package_name)
    if status == -1
      return -1
    end

    # 4. Update the Appfile (part of the Fastlane package)
    #    TODO? It depends if the package name in Fastlane actually makes a
    #    difference to the package name in the release build.
    # appfile_package_name = FileHandling.get_package_name_from_appfile(fastlane_directory)
    # if appfile_package_name != new_package_name
    #   FileHandling.set_package_name_in_appfile(fastlane_directory, appfile_package_name, new_package_name)
    # end
  end

  def self.update_manifests(source_directory, profiles, new_package_name)
    # Convert the profile names into directories
    profile_directories = []
    profiles.each do |profile|
      profile_directories.push(profile + "/")
    end

    if !profiles.include?("main")
      profile_directories.push("main/")
    end

    old_package_name = ""
    profile_directories.each do |profile_directory|
      # For each profile, update the package name in the manifest.
      path = source_directory + profile_directory
      old_package_name = FileHandling.get_package_name_from_manifest(path)
      if old_package_name == -1
        # An error went wrong. Pass it back up the calling tree
        return -1
      elsif old_package_name != new_package_name
        # We need to updated the package name to the new package name.
        if FileHandling.set_package_name_in_manifest(path, old_package_name, new_package_name) == -1
          # Something went wrong. Pass it back up the calling tree.
          return -1
        end
      end
    end
  end

  def self.rename_package_in_code_file(code_file_path, old_package_name, new_package_name)
    if !File.exist?(code_file_path)
      Fastlane::UI.user_error!("The provided code file path [#{file_path}] does not exist (current dir: [#{Dir.pwd}]")
      return -1
    end

    file_data = File.read(code_file_path)
    new_file_data = file_data.gsub(old_package_name, new_package_name)
    File.write(code_file_path, new_file_data)

    return 0
  end

  def self.move_code_files(source_directory, language, old_package_name, new_package_name)
    code_path = source_directory + "main/" + language.downcase + "/"
    code_directory_new = code_path + new_package_name.gsub(".", "/") + "/"
    code_directory_old = code_path + old_package_name.gsub(".", "/") + "/" # Use the package name obtained from previous step
    if !Dir.exist?(code_directory_new) || Dir.empty?(code_directory_new)
      # Create the new folder if it doesn't already exist.
      FileUtils.mkdir_p(code_directory_new)

      # When moving files, assume the previous directory is that of the release
      # package name structure.
      Dir.entries(code_directory_old).each do |file|
        file_path = code_directory_old + file
        if file == "." || file == ".." || !File.exist?(file_path) || File.directory?(file_path)
          next
        end

        # TODO: Apply moving files to nested folders and code files.

        # Update the package reference to the new name
        rename_package_in_code_file(file_path, old_package_name, new_package_name)

        # Move files - https://ruby-doc.org/stdlib-2.4.1/libdoc/fileutils/rdoc/FileUtils.html#method-c-mv
        FileUtils.mv(file_path, code_directory_new + file, force: true)
      end
    end
  end

  def self.update_gradle(gradle_directory, new_package_name)
    gradle_package_name = FileHandling.get_package_name_from_gradle(gradle_directory)
    if gradle_package_name == -1
      return -1
    elsif gradle_package_name != new_package_name
      FileHandling.set_package_name_in_gradle(gradle_directory, gradle_package_name, new_package_name)
    end

    return 0
  end
end
