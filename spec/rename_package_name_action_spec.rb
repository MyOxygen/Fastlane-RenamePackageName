describe Fastlane::Actions::RenamePackageNameAction do
  private
  VALID_PACKAGE_NAME = "com.example.app"
  private
  DEVELOP_PACKAGE_NAME = VALID_PACKAGE_NAME + ".develop"
  private
  INVALID_STRING_PARAMETERS = [nil, "", "   "]
  private
  VALID_PATH = "./"
  private
  VALID_PATH_WITH_FILES = "./spec/test_files/"
  private
  IOS_PROJECT_PATH = "#{VALID_PATH_WITH_FILES}ios_src/"
  private
  ANDROID_PROJECT_PATH = "#{VALID_PATH_WITH_FILES}android_src/"
  private
  SOURCE_DIRECTORY = "#{ANDROID_PROJECT_PATH}app/src/"
  private
  PROFILES = ["debug", "main"]

  # Setup
  # Runs this before every test (`it`)
  before(:each) do
    # Reset the files in the android_src/ directory
    SpecHelper.reset_testing_conditions
  end

  context "Displays user error when parameters are incorrect" do
    it "No parameters" do
      expect(Fastlane::UI).to receive(:user_error!)
      Fastlane::Actions::RenamePackageNameAction.run(nil)
    end

    it "Package name is not valid" do
      INVALID_STRING_PARAMETERS.each do |invalid_package_name|
        expect(Fastlane::UI).to receive(:user_error!)
        Fastlane::Actions::RenamePackageNameAction.run(new_package_name: invalid_package_name)
      end
    end

    it "Platform is not valid" do
      [nil, "", "   ", "mac", "windows", "linux", "literally anything else"].each do |invalid_platform|
        expect(Fastlane::UI).to receive(:user_error!)
        Fastlane::Actions::RenamePackageNameAction.run(
          new_package_name: VALID_PACKAGE_NAME,
          platform: invalid_platform
        )
      end
    end

    it "Android does not have the right parameters" do
      # Invalid project path
      INVALID_STRING_PARAMETERS.each do |invalid_parameter|
        expect(Fastlane::UI).to receive(:user_error!)
        Fastlane::Actions::RenamePackageNameAction.run(
          new_package_name: VALID_PACKAGE_NAME,
          platform: "android",
          project_home_path: invalid_parameter
        )
      end

      # Invalid profiles
      INVALID_STRING_PARAMETERS.each do |invalid_parameter|
        expect(Fastlane::UI).to receive(:user_error!)
        Fastlane::Actions::RenamePackageNameAction.run(
          new_package_name: VALID_PACKAGE_NAME,
          platform: "android",
          project_home_path: VALID_PATH
        )
      end
    end

    it "iOS does not have the right parameters" do
      # Invalid project path
      INVALID_STRING_PARAMETERS.each do |invalid_parameter|
        expect(Fastlane::UI).to receive(:user_error!)
        Fastlane::Actions::RenamePackageNameAction.run(
          new_package_name: VALID_PACKAGE_NAME,
          platform: "ios",
          xcodeproj: invalid_parameter
        )
      end

      # Invalid Info.plist path
      INVALID_STRING_PARAMETERS.each do |invalid_parameter|
        expect(Fastlane::UI).to receive(:user_error!)
        Fastlane::Actions::RenamePackageNameAction.run(
          new_package_name: VALID_PACKAGE_NAME,
          platform: "ios",
          xcodeproj: VALID_PATH,
          plist_path: invalid_parameter
        )
      end
    end
  end

  context "Full Android package name change works correctly" do
    it "Modify package names for Kotlin project" do
      kotlin_code_path = "#{SOURCE_DIRECTORY}main/kotlin/com/example/app/"
      kotlin_filename = "MainActivity.kt"

      Fastlane::Actions::RenamePackageNameAction.run(
        project_home_path: ANDROID_PROJECT_PATH,
        new_package_name: DEVELOP_PACKAGE_NAME,
        platform: "android",
        profiles: PROFILES
      )

      expect(Dir.exist?("#{kotlin_code_path}develop/")).to eq(true)
      expect(Dir.empty?("#{kotlin_code_path}develop/")).to eq(false)
      expect(File.exist?("#{kotlin_code_path}#{kotlin_filename}")).to eq(false)
      expect(File.exist?("#{kotlin_code_path}develop/#{kotlin_filename}")).to eq(true)

      package_name = FileHandling.get_package_name_from_kotlin_codefile("#{kotlin_code_path}develop/#{kotlin_filename}")
      expect(package_name).to eq(DEVELOP_PACKAGE_NAME)
      PROFILES.each do |profile|
        package_name = FileHandling.get_package_name_from_manifest(SOURCE_DIRECTORY + profile)
        expect(package_name).to eq(DEVELOP_PACKAGE_NAME)
      end
      package_name = FileHandling.get_package_name_from_gradle(ANDROID_PROJECT_PATH + "app/")
      expect(package_name).to eq(DEVELOP_PACKAGE_NAME)
    end

    it "Modify package names for Java project" do
      java_code_path = "#{SOURCE_DIRECTORY}main/java/com/example/app/"
      java_filename = "MainApplication.java"

      Fastlane::Actions::RenamePackageNameAction.run(
        project_home_path: ANDROID_PROJECT_PATH,
        new_package_name: DEVELOP_PACKAGE_NAME,
        platform: "android",
        profiles: PROFILES
      )

      expect(Dir.exist?("#{java_code_path}develop/")).to eq(true)
      expect(Dir.empty?("#{java_code_path}develop/")).to eq(false)
      expect(File.exist?("#{java_code_path}#{java_filename}")).to eq(false)
      expect(File.exist?("#{java_code_path}develop/#{java_filename}")).to eq(true)

      package_name = FileHandling.get_package_name_from_java_codefile("#{java_code_path}develop/#{java_filename}")
      expect(package_name).to eq(DEVELOP_PACKAGE_NAME)
      PROFILES.each do |profile|
        package_name = FileHandling.get_package_name_from_manifest(SOURCE_DIRECTORY + profile)
        expect(package_name).to eq(DEVELOP_PACKAGE_NAME)
      end
      package_name = FileHandling.get_package_name_from_gradle(ANDROID_PROJECT_PATH + "app/")
      expect(package_name).to eq(DEVELOP_PACKAGE_NAME)
    end

    it "Modify Appfile" do
      Fastlane::Actions::RenamePackageNameAction.run(
        project_home_path: ANDROID_PROJECT_PATH,
        new_package_name: DEVELOP_PACKAGE_NAME,
        platform: "android",
        profiles: PROFILES
      )

      package_name = FileHandling.get_package_name_from_appfile("#{ANDROID_PROJECT_PATH}fastlane/", FileHandling::APPFILE_ANDROID_ATTRIBUTE_REGEX)
      expect(package_name).to eq(DEVELOP_PACKAGE_NAME)
    end
  end
end
