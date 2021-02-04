require_relative "./file_handling.rb"
require_relative "./generic_helper.rb"

class AndroidHelper
  LANGUAGES = ["java", "kotlin"]

  def self.rename_package_names(project_home_path, new_package_name, profiles)
    # First check the parameters
    if GenericHelper.is_nil_or_whitespace(project_home_path)
      Fastlane::UI.user_error!("Invalid project home path: [#{project_home_path}]")
      return -1
    end

    path = GenericHelper.append_directory_separator(project_home_path)

    gradle_directory = path + "app/"
    fastlane_directory = path + "fastlane/"
    source_directory = gradle_directory + "src/"

    if GenericHelper.is_nil_or_whitespace(new_package_name)
      Fastlane::UI.user_error!("Invalid package name: [#{new_package_name}]")
      return -1
    end

    if GenericHelper.is_nil_or_empty(profiles)
      Fastlane::UI.user_error!("Invalid profiles")
      return -1
    end

    # 1. Determine if we need to change the package name throughout the
    #    Android project.
    old_package_name = FileHandling.get_package_name_from_manifest(source_directory + profiles[0] + "/")
    if old_package_name == -1
      return -1
    elsif old_package_name == new_package_name
      # If the package names are the same, there's no point in wasting time
      # conducting this operation. Warn the user, and exit early.
      Fastlane::UI.important("The old package name in the AndroidManifest [#{old_package_name}] is the")
      Fastlane::UI.important("same as the desired new package name [#{new_package_name}]")
      Fastlane::UI.important("Skipping package renaming")
      return -1
    end

    # 2. If we get here, the new name differs from the old one, so we need to
    #    go through every file in every sub-folder, and replace every instance
    #    of the old package name with the new one.
    migrate_project(source_directory, old_package_name, new_package_name)

    # 3. Check if the package name needs changing in the app/build.gradle file.
    status = update_gradle(gradle_directory, new_package_name)
    if status == -1
      return -1
    end

    # 4. Update the Appfile (part of the Fastlane package)
    status = FileHandling.update_appfile(fastlane_directory, FileHandling::APPFILE_ANDROID_ATTRIBUTE_REGEX, new_package_name)
    if status == -1
      return -1
    end
  end

  def self.migrate_project(source_directory, old_package_name, new_package_name)
    source_directory = GenericHelper.append_directory_separator(source_directory)

    Dir.entries(source_directory).each do |file_entity|
      file_path = GenericHelper.append_directory_separator(source_directory + file_entity)
      if file_entity == "." || file_entity == ".." || !File.exist?(file_path)
        next
      end

      # If it's not a directory, it's a file. Therefore, update the file with
      # the new package name.
      if !File.directory?(file_path)
        # Update this file with the package reference to the new package name.
        rename_package_in_code_file(file_path, old_package_name, new_package_name)
        next
      end

      # If the folder is not a language folder (java/kotlin), then we need to
      # dive into the folder to apply the renaming to the other files.
      if !LANGUAGES.include?(file_entity)
        # The folder is not the language directory. Dive deeper.
        migrate_project(file_path, old_package_name, new_package_name)

        # Once completed, move on to the next file/folder.
        next
      end

      # We are going to handle things a bit differently if we are in a language
      # directory. We want to move files first, then rename the package within.

      # Navigate through the sub-folders and update the files in each folder.

      code_directory_new = GenericHelper.append_directory_separator(file_path + new_package_name.gsub(".", "/"))
      code_directory_old = GenericHelper.append_directory_separator(file_path + old_package_name.gsub(".", "/"))

      # Check the assumed old directory actually exists
      if !File.exist?(code_directory_old)
        # The path is valid, but it is not the folder in which we need to
        # migrate code in. Dive deeper, and modify the files within.
        migrate_project(file_path, old_package_name, new_package_name)
        next
      end

      # Move the files.
      move_code_files(code_directory_old, code_directory_new)

      # Replace any instances of the old package name with the new package name
      refactor_code_files(code_directory_new, old_package_name, new_package_name)
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

  def self.move_code_files(old_directory, new_directory)
    old_directory = GenericHelper.append_directory_separator(old_directory)
    new_directory = GenericHelper.append_directory_separator(new_directory)

    Dir.entries(old_directory).each do |file_entity|
      full_path = GenericHelper.append_directory_separator(old_directory + file_entity)
      if file_entity == "." || file_entity == ".." || !File.exist?(full_path)
        # Invalid file. Move on.
        next
      end

      # If the full path we need to move from is the same as the path we need
      # to move to, don't do anything. Proceed to the next file/folder.
      if File.identical?(new_directory, full_path)
        next
      end

      # If the path is a folder, go in it to move the files.
      if File.directory?(full_path)
        # We want to maintain the folder structure, so append the `file_entity`
        # to the new directory.
        move_code_files(full_path, new_directory + file_entity)
      else
        # Create the destination folder if it does not exist.
        FileUtils.mkdir_p(new_directory)

        if !File.identical?(full_path, new_directory + file_entity)
          FileUtils.mv(full_path, new_directory + file_entity, force: true)
        end
      end
    end
  end

  def self.refactor_code_files(code_directory, old_package_name, new_package_name)
    code_directory = GenericHelper.append_directory_separator(code_directory)

    Dir.entries(code_directory).each do |file|
      file_path = code_directory + file
      if file == "." || file == ".." || !File.exist?(file_path)
        next
      end

      # Check for nested directories.
      if File.directory?(file_path)
        # If the path is a directory, we need to refactor all the files within
        # so that all instances of the old package name is replaced with the
        # new package name.
        refactor_code_files(file_path, old_package_name, new_package_name)

        # Once the above has completed, we can continue to the next file or
        # folder (if any are left).
        next
      end

      # Update the package reference to the new name
      rename_package_in_code_file(file_path, old_package_name, new_package_name)
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
