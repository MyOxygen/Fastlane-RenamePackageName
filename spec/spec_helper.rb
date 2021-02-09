$LOAD_PATH.unshift(File.expand_path('../../lib', __FILE__))

require 'simplecov'

# SimpleCov.minimum_coverage 95
SimpleCov.start

# This module is only used to check the environment is currently a testing env
module SpecHelper
  STATIC_FILES = "./spec/test_files/static_files/"
  DYNAMIC_FILES = "./spec/test_files/dynamic_files/"
  RELEASE_PACKAGE_NAME = "com.example.app"
  DEVELOP_PACKAGE_NAME = "com.example.app.develop"
  VALID_PATH_WITH_FILES = "./spec/test_files/"

  # Android
  ANDROID_PROJECT_PATH = "#{VALID_PATH_WITH_FILES}android_src/"
  FASTLANE_ANDROID_DIRECTORY = "#{ANDROID_PROJECT_PATH}fastlane/"
  SOURCE_DIRECTORY = "#{ANDROID_PROJECT_PATH}app/src/"
  JAVA_CODE_PATH = "#{SOURCE_DIRECTORY}main/java/com/example/app/"
  KOTLIN_CODE_PATH = "#{SOURCE_DIRECTORY}main/kotlin/com/example/app/"
  JAVA_FILENAME = "MainApplication.java"
  KOTLIN_FILENAME = "MainActivity.kt"

  # iOS
  PBXPROJ = "project.pbxproj"
  INFO_PLIST = "Info.plist"
  IOS_PROJECT_PATH = "#{VALID_PATH_WITH_FILES}ios_src/"
  FASTLANE_IOS_DIRECTORY = "#{IOS_PROJECT_PATH}fastlane/"
  PBXPROJ_DEST_PATH = "#{IOS_PROJECT_PATH}Runner.xcodeproj/"
  INFO_PLIST_DEST_PATH = "#{IOS_PROJECT_PATH}Runner/"
  PBXPROJ_PATH = "#{PBXPROJ_DEST_PATH}#{PBXPROJ}"
  INFO_PLIST_PATH = "#{INFO_PLIST_DEST_PATH}#{INFO_PLIST}"

  def self.reset_testing_conditions
    # AndroidManifest
    VALID_PROFILES.each do |manifest_location|
      FileUtils.cp_r(
        STATIC_FILES + "AndroidManifest.xml",
        "#{SOURCE_DIRECTORY}#{manifest_location}/",
        remove_destination: true
      )
    end

    # build.gradle
    FileUtils.cp_r(
      STATIC_FILES + "build.gradle",
      "#{ANDROID_PROJECT_PATH}app/",
      remove_destination: true
    )

    # Code files - Kotlin
    kotlin_code_path_develop = KOTLIN_CODE_PATH + "develop/"
    FileUtils.mkdir_p(KOTLIN_CODE_PATH)
    if Dir.exist?(kotlin_code_path_develop)
      FileUtils.remove_dir(kotlin_code_path_develop, force: true)
    end
    FileUtils.cp_r(
      STATIC_FILES + KOTLIN_FILENAME,
      KOTLIN_CODE_PATH,
      remove_destination: true
    )

    # Code files - Java
    java_code_path_develop = JAVA_CODE_PATH + "develop/"
    FileUtils.mkdir_p(JAVA_CODE_PATH)
    if Dir.exist?(java_code_path_develop)
      FileUtils.remove_dir(java_code_path_develop, force: true)
    end
    FileUtils.cp_r(
      STATIC_FILES + JAVA_FILENAME,
      JAVA_CODE_PATH,
      remove_destination: true
    )

    # iOS project files
    FileUtils.cp_r(
      STATIC_FILES + PBXPROJ,
      PBXPROJ_PATH,
      remove_destination: true
    )
    FileUtils.cp_r(
      STATIC_FILES + INFO_PLIST,
      INFO_PLIST_PATH,
      remove_destination: true
    )

    # Appfiles
    FileUtils.cp_r(
      STATIC_FILES + FileHandling::APP_FILE + "Android",
      FASTLANE_ANDROID_DIRECTORY + FileHandling::APP_FILE,
      remove_destination: true
    )
    FileUtils.cp_r(
      STATIC_FILES + FileHandling::APP_FILE + "Ios",
      FASTLANE_IOS_DIRECTORY + FileHandling::APP_FILE,
      remove_destination: true
    )

    # Matchfile
    FileUtils.cp_r(
      STATIC_FILES + FileHandling::MATCH_FILE,
      FASTLANE_IOS_DIRECTORY + FileHandling::MATCH_FILE,
      remove_destination: true
    )
  end

  def self.reset_dyamic_files
    # Copy all the static files into the dynamic folder
    FileUtils.cp_r(
      STATIC_FILES + JAVA_FILENAME,
      DYNAMIC_FILES + JAVA_FILENAME,
      remove_destination: true
    )
    FileUtils.cp_r(
      STATIC_FILES + KOTLIN_FILENAME,
      DYNAMIC_FILES + KOTLIN_FILENAME,
      remove_destination: true
    )
    FileUtils.cp_r(
      STATIC_FILES + FileHandling::MANIFEST_FILE,
      DYNAMIC_FILES + FileHandling::MANIFEST_FILE,
      remove_destination: true
    )
    FileUtils.cp_r(
      STATIC_FILES + FileHandling::GRADLE_FILE,
      DYNAMIC_FILES + FileHandling::GRADLE_FILE,
      remove_destination: true
    )
  end
end

require 'fastlane' # to import the Action super class
require 'fastlane/plugin/rename_package_name' # import the actual plugin

Fastlane.load_actions # load other actions (in case your plugin calls other actions or shared values)
