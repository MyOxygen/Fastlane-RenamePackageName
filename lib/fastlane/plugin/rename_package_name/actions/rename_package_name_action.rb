require 'fastlane/action'
require_relative '../helper/android_helper'

module Fastlane
  module Actions
    class RenamePackageNameAction < Action
      def self.run(params)
        platform = params[:platform]
        project_home_path = params[:project_home_path]
        new_package_name = params[:new_package_name]
        profiles = params[:profiles]
        language = params[:language]

        puts "Parameters received:"
        puts "Platform: " + platform
        puts "Project home path: " + project_home_path
        puts "New package name: " + new_package_name
        puts "Profiles: " + profiles.join(", ")
        puts "Language: " + language

        if platform != nil
          platform = platform.downcase
          if platform == "ios"
            puts "I am on iOS!"
          elsif platform == "android"
            Android.rename_package_names(project_home_path, new_package_name, profiles, language)
          end
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
          FastlaneCore::ConfigItem.new(key: :project_home_path,
                                  env_name: "RENAME_PACKAGE_NAME_PROJECT_HOME_PATH",
                               description: "The home path of the project to which this code will execute in",
                                  optional: false,
                                      type: String),
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
    end
  end
end
