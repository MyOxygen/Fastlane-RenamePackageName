describe IosHelper do
  private
  INVALID_STRINGS = [nil, "", "   "]
  private
  INVALID_ARRAYS = [nil, []]

  private
  INVALID_PATHS = INVALID_STRINGS
  private
  VALID_PATH_NO_FILES = "./"

  private
  VALID_PACKAGE_NAME = SpecHelper::RELEASE_PACKAGE_NAME

  private
  INFO_PLIST_PATH_RELATIVE_TO_XCODEPROJ = "Runner/Info.plist"

  # Setup
  # Runs this before every test (`it`)
  before(:each) do
    # Reset the files in the android_src/ directory
    SpecHelper.reset_testing_conditions
  end

  context "Handles invalid parameters" do
    it "Invalid path" do
      INVALID_PATHS.each do |invalid_path|
        expect(Fastlane::UI).to receive(:user_error!)
        IosHelper.rename_package_names(
          invalid_path,
          SpecHelper::RELEASE_PACKAGE_NAME,
          VALID_PATH_NO_FILES,
          VALID_PATH_NO_FILES
        )
      end
    end

    it "Invalid package name" do
      INVALID_STRINGS.each do |invalid_package_name|
        expect(Fastlane::UI).to receive(:user_error!)
        IosHelper.rename_package_names(
          SpecHelper::IOS_PROJECT_PATH,
          invalid_package_name,
          VALID_PATH_NO_FILES,
          VALID_PATH_NO_FILES
        )
      end
    end

    it "Invalid xcodeproj" do
      INVALID_PATHS.each do |invalid_path|
        expect(Fastlane::UI).to receive(:user_error!)
        IosHelper.rename_package_names(
          SpecHelper::IOS_PROJECT_PATH,
          SpecHelper::RELEASE_PACKAGE_NAME,
          invalid_path,
          VALID_PATH_NO_FILES
        )
      end
    end

    it "Invalid plist_path" do
      invalid_languages = INVALID_LANGUAGES + []
      INVALID_PATHS.each do |invalid_path|
        expect(Fastlane::UI).to receive(:user_error!)
        IosHelper.rename_package_names(
          SpecHelper::IOS_PROJECT_PATH,
          SpecHelper::RELEASE_PACKAGE_NAME,
          VALID_PATH_NO_FILES,
          invalid_path
        )
      end
    end
  end

  context "Displays user error when path is not found" do
    it "Valid path, but does not exist" do
      expect(Fastlane::UI).to receive(:user_error!)
      IosHelper.rename_package_names(
        VALID_PATH_NO_FILES, # Valid path, but no valid files in this directory
        SpecHelper::RELEASE_PACKAGE_NAME,
        VALID_PATH_NO_FILES,
        VALID_PATH_NO_FILES
      )
    end
  end

  context "Files refactored successfully" do
    it "PBXPROJ" do
      expect(Fastlane::UI).not_to receive(:user_error!)
      status = IosHelper.rename_package_names(
        SpecHelper::IOS_PROJECT_PATH,
        SpecHelper::DEVELOP_PACKAGE_NAME,
        SpecHelper::PBXPROJ_DEST_PATH,
        INFO_PLIST_PATH_RELATIVE_TO_XCODEPROJ
      )
      expect(status).not_to eq(-1)

      package_name = FileHandling.get_package_name_from_xcode_project_file(SpecHelper::PBXPROJ_PATH)
      expect(package_name).to eq(DEVELOP_PACKAGE_NAME)
    end

    it "Appfile" do
      expect(Fastlane::UI).not_to receive(:user_error!)
      status = IosHelper.rename_package_names(
        SpecHelper::IOS_PROJECT_PATH,
        SpecHelper::DEVELOP_PACKAGE_NAME,
        SpecHelper::PBXPROJ_DEST_PATH,
        INFO_PLIST_PATH_RELATIVE_TO_XCODEPROJ
      )
      expect(status).not_to eq(-1)

      package_name = FileHandling.get_package_name_from_appfile(SpecHelper::FASTLANE_IOS_DIRECTORY, FileHandling::APPFILE_IOS_ATTRIBUTE_REGEX)
      expect(package_name).to eq(DEVELOP_PACKAGE_NAME)
    end

    it "Matchfile" do
      expect(Fastlane::UI).not_to receive(:user_error!)
      status = IosHelper.rename_package_names(
        SpecHelper::IOS_PROJECT_PATH,
        SpecHelper::DEVELOP_PACKAGE_NAME,
        SpecHelper::PBXPROJ_DEST_PATH,
        INFO_PLIST_PATH_RELATIVE_TO_XCODEPROJ
      )
      expect(status).not_to eq(-1)

      package_name = FileHandling.get_package_name_from_matchfile(SpecHelper::FASTLANE_IOS_DIRECTORY)
      expect(package_name).to eq(DEVELOP_PACKAGE_NAME)
    end
  end
end
