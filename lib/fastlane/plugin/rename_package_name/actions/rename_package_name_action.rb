require 'fastlane/action'
require_relative '../helper/rename_package_name_helper'

module Fastlane
  module Actions
    class RenamePackageNameAction < Action
      def self.run(params)
        UI.message("The rename_package_name plugin is working!")
      end

      def self.description
        "A shorthand way of renaming the package name (App ID / Bundle ID) of an app in Fastlane."
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
          # FastlaneCore::ConfigItem.new(key: :your_option,
          #                         env_name: "RENAME_PACKAGE_NAME_YOUR_OPTION",
          #                      description: "A description of your option",
          #                         optional: false,
          #                             type: String)
        ]
      end

      def self.is_supported?(platform)
        # Adjust this if your plugin only works for a particular platform (iOS vs. Android, for example)
        # See: https://docs.fastlane.tools/advanced/#control-configuration-by-lane-and-by-platform
        #
        # [:ios, :mac, :android].include?(platform)
        true
      end
    end
  end
end
