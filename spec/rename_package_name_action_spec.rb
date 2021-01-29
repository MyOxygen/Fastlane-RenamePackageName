describe Fastlane::Actions::RenamePackageNameAction do
  private
  VALID_PACKAGE_NAME = "com.example.app"
  private
  INVALID_STRING_PARAMETERS = [nil, "", "   "]
  private
  VALID_PATH = "./"

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
          android_project_home_path: invalid_parameter
        )
      end

      # Invalid programming language
      INVALID_STRING_PARAMETERS.each do |invalid_parameter|
        expect(Fastlane::UI).to receive(:user_error!)
        Fastlane::Actions::RenamePackageNameAction.run(
          new_package_name: VALID_PACKAGE_NAME,
          platform: "android",
          android_project_home_path: VALID_PATH,
          language: invalid_parameter
        )
      end

      # Invalid profiles
      INVALID_STRING_PARAMETERS.each do |invalid_parameter|
        expect(Fastlane::UI).to receive(:user_error!)
        Fastlane::Actions::RenamePackageNameAction.run(
          new_package_name: VALID_PACKAGE_NAME,
          platform: "android",
          android_project_home_path: VALID_PATH,
          language: "kotlin"
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
      develop_package_name = VALID_PACKAGE_NAME + ".develop"
      profiles = ["debug/", "main/"]

      valid_path_with_files = "./spec/test_files/android_src/"
      source_directory = "#{valid_path_with_files}app/src/"
      kotlin_code_path = "#{source_directory}main/kotlin/com/example/app/"
      kotlin_filename = "MainActivity.kt"

      Fastlane::Actions::RenamePackageNameAction.run(
        android_project_home_path: valid_path_with_files,
        new_package_name: develop_package_name,
        platform: "android",
        profiles: profiles,
        language: "kotlin"
      )

      expect(Dir.exist?("#{kotlin_code_path}develop/")).to eq(true)
      expect(Dir.empty?("#{kotlin_code_path}develop/")).to eq(false)
      expect(File.exist?("#{kotlin_code_path}#{kotlin_filename}")).to eq(false)
      expect(File.exist?("#{kotlin_code_path}develop/#{kotlin_filename}")).to eq(true)

      package_name = FileHandling.get_package_name_from_kotlin_codefile("#{kotlin_code_path}develop/#{kotlin_filename}")
      expect(package_name).to eq(DEVELOP_PACKAGE_NAME)
      profiles.each do |profile|
        package_name = FileHandling.get_package_name_from_manifest(source_directory + profile)
        expect(package_name).to eq(DEVELOP_PACKAGE_NAME)
      end
      package_name = FileHandling.get_package_name_from_gradle(valid_path_with_files + "app/")
      expect(package_name).to eq(DEVELOP_PACKAGE_NAME)
    end

    it "Modify package names for Java project" do
      develop_package_name = VALID_PACKAGE_NAME + ".develop"
      profiles = ["debug/", "main/"]

      valid_path_with_files = "./spec/test_files/android_src/"
      source_directory = "#{valid_path_with_files}app/src/"
      java_code_path = "#{source_directory}main/java/com/example/app/"
      java_filename = "MainApplication.java"

      Fastlane::Actions::RenamePackageNameAction.run(
        android_project_home_path: valid_path_with_files,
        new_package_name: develop_package_name,
        platform: "android",
        profiles: profiles,
        language: "java"
      )

      expect(Dir.exist?("#{java_code_path}develop/")).to eq(true)
      expect(Dir.empty?("#{java_code_path}develop/")).to eq(false)
      expect(File.exist?("#{java_code_path}#{java_filename}")).to eq(false)
      expect(File.exist?("#{java_code_path}develop/#{java_filename}")).to eq(true)

      package_name = FileHandling.get_package_name_from_java_codefile("#{java_code_path}develop/#{java_filename}")
      expect(package_name).to eq(DEVELOP_PACKAGE_NAME)
      profiles.each do |profile|
        package_name = FileHandling.get_package_name_from_manifest(source_directory + profile)
        expect(package_name).to eq(DEVELOP_PACKAGE_NAME)
      end
      package_name = FileHandling.get_package_name_from_gradle(valid_path_with_files + "app/")
      expect(package_name).to eq(DEVELOP_PACKAGE_NAME)
    end
  end
end
