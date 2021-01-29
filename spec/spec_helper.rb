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
  VALID_PATH_WITH_FILES = "./spec/test_files/android_src/"
  SOURCE_DIRECTORY = "#{VALID_PATH_WITH_FILES}app/src/"
  JAVA_CODE_PATH = "#{SOURCE_DIRECTORY}main/java/com/example/app/"
  KOTLIN_CODE_PATH = "#{SOURCE_DIRECTORY}main/kotlin/com/example/app/"
  JAVA_FILENAME = "MainApplication.java"
  KOTLIN_FILENAME = "MainActivity.kt"

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
      "#{VALID_PATH_WITH_FILES}app/",
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
