require 'fastlane/action'
require_relative '../helper/android_helper'
require_relative '../helper/generic_helper'

module Fastlane
  module Actions
    class RenamePackageNameAction < Action
      def self.run(params)
        # Check there are incoming parameters. Note that the parameters are not
        # in an array, but a FastlaneCore::Configuration object. Whilst this
        # object does have an array of parameters, we will need to first check
        # that such an object has been passed to obtain the parameters. We can
        # check the validity of contents later.
        if params.nil?
          UI.user_error!("`rename_package_name` must have parameters")
          return
        end

        platform = params[:platform]
        new_package_name = params[:new_package_name]
        project_home_path = params[:project_home_path]

        if GenericHelper.is_nil_or_whitespace(project_home_path)
          UI.user_error!("The project home path must not be empty")
          return
        elsif GenericHelper.is_nil_or_whitespace(new_package_name)
          UI.user_error!("The new package name must not be empty")
          return
        elsif GenericHelper.is_nil_or_whitespace(platform)
          UI.user_error!("The platform must be specified")
          return
        end

        platform = platform.downcase
        if platform == "ios"
          # For iOS, we need the xcodeproj and plist_path.

          xcodeproj = params[:xcodeproj]
          plist_path = params[:plist_path]

          # Both the Xcode project file and the Info.plist file are required.
          if GenericHelper.is_nil_or_whitespace(xcodeproj)
            UI.user_error!("The Xcode Project path must not be empty")
            return
          elsif GenericHelper.is_nil_or_whitespace(plist_path)
            UI.user_error!("The Info.plist path must not be empty")
            return
          end

          # Required values are not empty, so we can carry out the renaming.
          IosHelper.rename_package_names(project_home_path, new_package_name, xcodeproj, plist_path)
        elsif platform == "android"
          # For Android, we need the the profiles.
          profiles = params[:profiles]

          # The profiles are optional and defaulted.

          # Required values are not empty, so we can carry out the renaming.
          AndroidHelper.rename_package_names(project_home_path, new_package_name, profiles)
        else
          UI.user_error!("Platform not supported")
          return
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
        "The plugin goes through both Android and iOS, and replaces the App ID (Android) " \
          "and Bundle ID (iOS) with a new name. For Android, it also goes through the native " \
          "files and folders, renaming the package reference, the applicationId in the gradle, " \
          "the package attribute in the manifest, and moves the files into thee new folder structure " \
          "(as per the new package name)."
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
          FastlaneCore::ConfigItem.new(key: :project_home_path,
                                  env_name: "RENAME_PACKAGE_NAME_PROJECT_HOME_PATH",
                               description: "The home path of the project to which this code will execute in",
                                  optional: false,
                                      type: String),
          # Optional parameters
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
                                      type: Array)
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
