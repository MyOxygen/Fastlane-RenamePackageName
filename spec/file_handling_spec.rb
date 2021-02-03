describe FileHandling do
  private
  INVALID_DIRECTORY = "./"
  private
  STATIC_DIRECTORY = "./spec/test_files/static_files/"
  private
  TEST_DIRECTORY = "./spec/test_files/dynamic_files/"
  private
  STATIC_PACKAGE_NAME = "com.example.app"
  private
  RELEASE_PACKAGE_NAME = "com.example.app"
  private
  DEVELOP_PACKAGE_NAME = "com.example.app.develop"
  private
  JAVA_CODEFILE_STATIC_PATH = STATIC_DIRECTORY + "MainApplication.java"
  private
  KOTLIN_CODEFILE_STATIC_PATH = STATIC_DIRECTORY + "MainActivity.kt"
  private
  JAVA_CODEFILE_DYNAMIC_PATH = TEST_DIRECTORY + "MainApplication.java"
  private
  KOTLIN_CODEFILE_DYNAMIC_PATH = TEST_DIRECTORY + "MainActivity.kt"
  private
  APPFILE_ANDROID_STATIC_PATH = STATIC_DIRECTORY + FileHandling::APP_FILE + "Android"
  private
  APPFILE_IOS_STATIC_PATH = STATIC_DIRECTORY + FileHandling::APP_FILE + "Ios"
  private
  MATCHFILE_STATIC_PATH = STATIC_DIRECTORY + FileHandling::MATCH_FILE
  private
  APPFILE_DYNAMIC_PATH = TEST_DIRECTORY + FileHandling::APP_FILE
  private
  MATCHFILE_DYNAMIC_PATH = TEST_DIRECTORY + FileHandling::MATCH_FILE

  # Setup
  before (:each) do
    # Copy all the static files into the dynamic folder
    manifest_dynamic_location = TEST_DIRECTORY + FileHandling::MANIFEST_FILE
    gradle_dynamic_location = TEST_DIRECTORY + FileHandling::GRADLE_FILE
    FileUtils.cp_r(
      JAVA_CODEFILE_STATIC_PATH,
      JAVA_CODEFILE_DYNAMIC_PATH,
      remove_destination: true
    )
    FileUtils.cp_r(
      KOTLIN_CODEFILE_STATIC_PATH,
      KOTLIN_CODEFILE_DYNAMIC_PATH,
      remove_destination: true
    )
    FileUtils.cp_r(
      STATIC_DIRECTORY + FileHandling::MANIFEST_FILE,
      manifest_dynamic_location,
      remove_destination: true
    )
    FileUtils.cp_r(
      STATIC_DIRECTORY + FileHandling::GRADLE_FILE,
      gradle_dynamic_location,
      remove_destination: true
    )
    # Don't copy the Appfiles. These are done in the tests.
    FileUtils.cp_r(
      MATCHFILE_STATIC_PATH,
      MATCHFILE_DYNAMIC_PATH,
      remove_destination: true
    )
  end

  context "Handles file not found" do
    it "AndroidManifest not found" do
      expect(Fastlane::UI).to receive(:user_error!)
      name = FileHandling.get_package_name_from_manifest(INVALID_DIRECTORY)
    end

    it "build.gradle not found" do
      expect(Fastlane::UI).to receive(:user_error!)
      name = FileHandling.get_package_name_from_gradle(INVALID_DIRECTORY)
    end
  end

  context "Reading package name works" do
    it "Successfully reads package name from AndroidManifest" do
      name = FileHandling.get_package_name_from_manifest(STATIC_DIRECTORY)
      expect(name).to eq(STATIC_PACKAGE_NAME)
    end

    it "Successfully reads package name from build.gradle" do
      name = FileHandling.get_package_name_from_gradle(STATIC_DIRECTORY)
      expect(name).to eq(STATIC_PACKAGE_NAME)
    end

    it "Successfully reads package name from a Kotlin codefile" do
      name = FileHandling.get_package_name_from_kotlin_codefile(KOTLIN_CODEFILE_STATIC_PATH)
      expect(name).to eq(STATIC_PACKAGE_NAME)
    end

    it "Successfully reads package name from a Java codefile" do
      name = FileHandling.get_package_name_from_java_codefile(JAVA_CODEFILE_STATIC_PATH)
      expect(name).to eq(STATIC_PACKAGE_NAME)
    end
  end

  context "Renaming package and back" do
    it "Successfully renames AndroidManifest" do
      # Change package name to the develop package name
      current_package_name = FileHandling.get_package_name_from_manifest(TEST_DIRECTORY)
      FileHandling.set_package_name_in_manifest(TEST_DIRECTORY, current_package_name, DEVELOP_PACKAGE_NAME)
      new_package_name = FileHandling.get_package_name_from_manifest(TEST_DIRECTORY)
      expect(new_package_name).to eq(DEVELOP_PACKAGE_NAME)

      # Change package name back to release
      current_package_name = FileHandling.get_package_name_from_manifest(TEST_DIRECTORY)
      FileHandling.set_package_name_in_manifest(TEST_DIRECTORY, current_package_name, RELEASE_PACKAGE_NAME)
      new_package_name = FileHandling.get_package_name_from_manifest(TEST_DIRECTORY)
      expect(new_package_name).to eq(RELEASE_PACKAGE_NAME)
    end

    it "Successfully renames build.gradle" do
      # Change package name to the develop package name
      current_package_name = FileHandling.get_package_name_from_gradle(TEST_DIRECTORY)
      FileHandling.set_package_name_in_gradle(TEST_DIRECTORY, current_package_name, DEVELOP_PACKAGE_NAME)
      new_package_name = FileHandling.get_package_name_from_gradle(TEST_DIRECTORY)
      expect(new_package_name).to eq(DEVELOP_PACKAGE_NAME)

      # Change package name back to release
      current_package_name = FileHandling.get_package_name_from_gradle(TEST_DIRECTORY)
      FileHandling.set_package_name_in_gradle(TEST_DIRECTORY, current_package_name, RELEASE_PACKAGE_NAME)
      new_package_name = FileHandling.get_package_name_from_gradle(TEST_DIRECTORY)
      expect(new_package_name).to eq(RELEASE_PACKAGE_NAME)
    end

    it "Successfully renames Java codefile" do
      # Change package name to the develop package name
      current_package_name = FileHandling.get_package_name_from_java_codefile(JAVA_CODEFILE_DYNAMIC_PATH)
      FileHandling.set_package_name_in_file(JAVA_CODEFILE_DYNAMIC_PATH, current_package_name, DEVELOP_PACKAGE_NAME)
      new_package_name = FileHandling.get_package_name_from_java_codefile(JAVA_CODEFILE_DYNAMIC_PATH)
      expect(new_package_name).to eq(DEVELOP_PACKAGE_NAME)

      # Change package name back to release
      current_package_name = FileHandling.get_package_name_from_java_codefile(JAVA_CODEFILE_DYNAMIC_PATH)
      FileHandling.set_package_name_in_file(JAVA_CODEFILE_DYNAMIC_PATH, current_package_name, RELEASE_PACKAGE_NAME)
      new_package_name = FileHandling.get_package_name_from_java_codefile(JAVA_CODEFILE_DYNAMIC_PATH)
      expect(new_package_name).to eq(RELEASE_PACKAGE_NAME)
    end

    it "Successfully renames Kotlin codefile" do
      # Change package name to the develop package name
      current_package_name = FileHandling.get_package_name_from_kotlin_codefile(KOTLIN_CODEFILE_DYNAMIC_PATH)
      FileHandling.set_package_name_in_file(KOTLIN_CODEFILE_DYNAMIC_PATH, current_package_name, DEVELOP_PACKAGE_NAME)
      new_package_name = FileHandling.get_package_name_from_kotlin_codefile(KOTLIN_CODEFILE_DYNAMIC_PATH)
      expect(new_package_name).to eq(DEVELOP_PACKAGE_NAME)

      # Change package name back to release
      current_package_name = FileHandling.get_package_name_from_kotlin_codefile(KOTLIN_CODEFILE_DYNAMIC_PATH)
      FileHandling.set_package_name_in_file(KOTLIN_CODEFILE_DYNAMIC_PATH, current_package_name, RELEASE_PACKAGE_NAME)
      new_package_name = FileHandling.get_package_name_from_kotlin_codefile(KOTLIN_CODEFILE_DYNAMIC_PATH)
      expect(new_package_name).to eq(RELEASE_PACKAGE_NAME)
    end

    context "Successfully renames Appfile" do
      it "Android" do
        # Get the static Android Appfile from the static directory
        FileUtils.cp_r(
          APPFILE_ANDROID_STATIC_PATH,
          APPFILE_DYNAMIC_PATH,
          remove_destination: true
        )

        # Change package name to the develop package name
        FileHandling.update_appfile(TEST_DIRECTORY, FileHandling::APPFILE_ANDROID_ATTRIBUTE_REGEX, DEVELOP_PACKAGE_NAME)
        package_name = FileHandling.get_package_name_from_appfile(TEST_DIRECTORY, FileHandling::APPFILE_ANDROID_ATTRIBUTE_REGEX)
        expect(package_name).to eq(DEVELOP_PACKAGE_NAME)

        # Change package name back to release
        FileHandling.update_appfile(TEST_DIRECTORY, FileHandling::APPFILE_ANDROID_ATTRIBUTE_REGEX, RELEASE_PACKAGE_NAME)
        package_name = FileHandling.get_package_name_from_appfile(TEST_DIRECTORY, FileHandling::APPFILE_ANDROID_ATTRIBUTE_REGEX)
        expect(package_name).to eq(RELEASE_PACKAGE_NAME)
      end

      it "iOS" do
        # Get the static iOS Appfile from the static directory
        FileUtils.cp_r(
          APPFILE_IOS_STATIC_PATH,
          APPFILE_DYNAMIC_PATH,
          remove_destination: true
        )

        # Change package name to the develop package name
        FileHandling.update_appfile(TEST_DIRECTORY, FileHandling::APPFILE_IOS_ATTRIBUTE_REGEX, DEVELOP_PACKAGE_NAME)
        package_name = FileHandling.get_package_name_from_appfile(TEST_DIRECTORY, FileHandling::APPFILE_IOS_ATTRIBUTE_REGEX)
        expect(package_name).to eq(DEVELOP_PACKAGE_NAME)

        # Change package name back to release
        FileHandling.update_appfile(TEST_DIRECTORY, FileHandling::APPFILE_IOS_ATTRIBUTE_REGEX, RELEASE_PACKAGE_NAME)
        package_name = FileHandling.get_package_name_from_appfile(TEST_DIRECTORY, FileHandling::APPFILE_IOS_ATTRIBUTE_REGEX)
        expect(package_name).to eq(RELEASE_PACKAGE_NAME)
      end

      it "Incorrect regex throw error" do
        # Get the static Appfile from the static directory (Android or iOS, it
        # doesn't really matter)
        FileUtils.cp_r(
          APPFILE_IOS_STATIC_PATH,
          APPFILE_DYNAMIC_PATH,
          remove_destination: true
        )

        expect(Fastlane::UI).to receive(:user_error!)
        FileHandling.update_appfile(TEST_DIRECTORY, /invalid_regex/, DEVELOP_PACKAGE_NAME)
      end
    end

    it "Successfully renames Matchfile" do
      # Change package name to the develop package name
      FileHandling.update_matchfile(TEST_DIRECTORY, DEVELOP_PACKAGE_NAME)
      package_name = FileHandling.get_package_name_from_matchfile(TEST_DIRECTORY)
      expect(package_name).to eq(DEVELOP_PACKAGE_NAME)

      # Change package name back to release
      FileHandling.update_matchfile(TEST_DIRECTORY, RELEASE_PACKAGE_NAME)
      package_name = FileHandling.get_package_name_from_matchfile(TEST_DIRECTORY)
      expect(package_name).to eq(RELEASE_PACKAGE_NAME)
    end
  end
end
