require 'fastlane/action'
require_relative '../helper/android_helper'

module Fastlane
  module Actions
    class RenamePackageNameAction < Action
      def self.run(params)
        platform = params[:platform]
        new_package_name = params[:new_package_name]

        if is_nil_or_whitespace(new_package_name)
          UI.user_error!("The new package name must not be empty")
        elsif is_nil_or_whitespace(platform)
          UI.user_error!("The platform must be specified")
        end

        platform = platform.downcase
        if platform == "ios"
          # For iOS, we need the xcodeproj and plist_path. We will be using
          # the existing package provided by Fastlane: `update_app_identifier`
          # (https://docs.fastlane.tools/actions/update_app_identifier/).

          xcodeproj = params[:xcodeproj]
          plist_path = params[:plist_path]

          # Both the Xcode project file and the Info.plist file are required.
          if is_nil_or_whitespace(xcodeproj)
            UI.user_error!("The Xcode Project path must not be empty")
          elsif is_nil_or_whitespace(plist_path)
            UI.user_error!("The Info.plist path must not be empty")
          end

          # Required values are not empty, so we can carry out the renaming.
          # When calling an external action, use the action's class name.
          # Class name - https://github.com/fastlane/fastlane/blob/master/fastlane/lib/fastlane/actions/update_app_identifier.rb
          # Suggestion from - https://github.com/fastlane/fastlane/issues/826
          Fastlane::Actions::UpdateAppIdentifierAction.run(
            xcodeproj: xcodeproj,
            plist_path: plist_path,
            app_identifier: new_package_name
          )

        elsif platform == "android"
          # For Android, we need the project home path, the profiles, and the
          # language used.
          project_home_path = params[:android_project_home_path]
          profiles = params[:profiles]
          language = params[:language]

          # The project home path is required, but the profiles and the 
          # language used are optional. These are defaulted.
          if is_nil_or_whitespace(project_home_path)
            UI.user_error!("The project home path must not be empty")
          end

          # Required values are not empty, so we can carry out the renaming.
          Android.rename_package_names(project_home_path, new_package_name, profiles, language)
        end
      end

      def self.description
        "A shorthand way of renaming the package name (App ID / Bundle ID) of an app in Fastlane"
      end

      def self.authors
        ["tom-MO"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.details
        # Optional:
        "The plugin goes through both Android and iOS, and replaces the App ID (Android) and Bundle ID (iOS) with a new name. For Android, it also goes through the native files and folders, renaming the package reference, the applicationId in the gradle, the package attribute in the manifest, and moves the files into thee new folder structure (as per the new package name)."
      end

      def self.available_options
        [
          # Required parameters
          FastlaneCore::ConfigItem.new(key: :new_package_name,
                                  env_name: "RENAME_PACKAGE_NAME_NEW_PACKAGE_NAME",
                               description: "The package name to which to change to",
                                  optional: false,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :platform,
                                  env_name: "RENAME_PACKAGE_NAME_PLATFORM",
                               description: "The platform for which this code will execute in (android/ios)",
                                  optional: false,
                                      type: String),
          # Optional parameters
          FastlaneCore::ConfigItem.new(key: :android_project_home_path,
                                  env_name: "RENAME_PACKAGE_NAME_ANDROID_PROJECT_HOME_PATH",
                               description: "The home path of the project to which this code will execute in",
                                  optional: true,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :xcodeproj,
                                  env_name: "RENAME_PACKAGE_NAME_XCODEPROJ",
                                description: "The Xcode project file which belongs to this project",
                                  optional: true,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :plist_path,
                                  env_name: "RENAME_PACKAGE_NAME_PLIST_PATH",
                                description: "The path to info plist file, relative to xcodeproj",
                                  optional: true,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :profiles,
                                  env_name: "RENAME_PACKAGE_NAME_PROFILES",
                                description: "The list of profiles necessary to run on (Android only), and takes an array of Strings",
                                  optional: true,
                                      type: Array),
          FastlaneCore::ConfigItem.new(key: :language,
                                  env_name: "RENAME_PACKAGE_NAME_LANGUAGE",
                                description: "The native language used to write the native code (Android only)",
                                  optional: true,
                                      type: String)
        ]
      end

      def self.is_supported?(platform)
        # Adjust this if your plugin only works for a particular platform (iOS vs. Android, for example)
        # See: https://docs.fastlane.tools/advanced/#control-configuration-by-lane-and-by-platform
        #
        # [:ios, :mac, :android].include?(platform)
        [:ios, :android].include?(platform)
      end

      def self.is_nil_or_whitespace(string)
        return string == nil || string == "" || string.strip! != nil
      end

      def self.is_nil_or_empty(array)
        return array == nil || array.length == 0
      end
    end
  end
end
