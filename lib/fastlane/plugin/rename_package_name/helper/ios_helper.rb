require_relative "./file_handling.rb"
require_relative "./generic_helper.rb"

class IosHelper
  def self.rename_package_names(project_home_path, new_package_name, xcodeproj, plist_path)
    # First check the parameters
    if GenericHelper.is_nil_or_whitespace(project_home_path)
      Fastlane::UI.user_error!("Invalid project home path: [#{project_home_path}]")
      return -1
    end

    path = GenericHelper.append_directory_separator(project_home_path)
    fastlane_directory = path + "fastlane/"

    if GenericHelper.is_nil_or_whitespace(new_package_name)
      Fastlane::UI.user_error!("Invalid package name: [#{new_package_name}]")
      return -1
    end

    if GenericHelper.is_nil_or_whitespace(xcodeproj)
      Fastlane::UI.user_error!("Invalid Xcode project path")
      return -1
    end

    # The Xcode project file is actually a folder (despite having an extension).
    # The actual file we need to modify is within this folder.
    # TODO: make sure that this file name is the same across all iOS projects!
    project_file = xcodeproj + "/project.pbxproj"

    if GenericHelper.is_nil_or_whitespace(plist_path)
      Fastlane::UI.user_error!("Invalid info.plist path")
      return -1
    end

    # We have what we need. Let's get started.

    # 1. Get the old package name from the Xcode project file.
    old_package_name = FileHandling.get_package_name_from_xcode_project_file(project_file)
    if old_package_name == -1
      return -1
    elsif old_package_name == new_package_name
      # If the package names are the same, there's no point in wasting time
      # conducting this operation. Warn the user, and exit early.
      Fastlane::UI.important("The old package name in the Xcode project [#{old_package_name}] is the")
      Fastlane::UI.important("same as the desired new package name [#{new_package_name}]")
      Fastlane::UI.important("Skipping package renaming")
      return -1
    end

    # 2. If we get here, we need to update to the new package name. For iOS, we
    #    can simply change the bundle ID attribute in the Xcode project file.
    #    However, we should replace all instances of the old package name in
    #    the file, as it will no longer be valid.
    status = FileHandling.set_package_name_in_file(project_file, old_package_name, new_package_name)
    if status == -1
      return -1
    end

    # 3. Now we can update the project. We will be using the existing package
    #    provided by Fastlane: `update_app_identifier` (https://docs.fastlane.tools/actions/update_app_identifier/).

    # When calling an external action, use the action's class name.
    # Class name - https://github.com/fastlane/fastlane/blob/master/fastlane/lib/fastlane/actions/update_app_identifier.rb
    # Suggestion from - https://github.com/fastlane/fastlane/issues/826
    Fastlane::Actions::UpdateAppIdentifierAction.run(
      xcodeproj: xcodeproj,
      plist_path: plist_path,
      app_identifier: new_package_name
    )

    # 4. Update Fastlane-releated files (Matchfile is specific to iOS)
    status = FileHandling.update_appfile(fastlane_directory, FileHandling::APPFILE_IOS_ATTRIBUTE_REGEX, new_package_name)
    if status == -1
      return -1
    end
    status = FileHandling.update_matchfile(fastlane_directory, new_package_name)
    if status == -1
      return -1
    end
  end
end
