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

  # Setup
  before (:all) do
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

  context "Renaming package" do
    it "Successfully renames AndroidManifest" do
      current_package_name = FileHandling.get_package_name_from_manifest(TEST_DIRECTORY)
      expected_package_name = ""
      if current_package_name == RELEASE_PACKAGE_NAME
        expected_package_name = DEVELOP_PACKAGE_NAME
      elsif current_package_name == DEVELOP_PACKAGE_NAME
        expected_package_name = RELEASE_PACKAGE_NAME
      else
        # Any other name retrieved is wrong.
        expect(true).to eq(false), "The package name [#{current_package_name}] should either be release or develop"
      end

      FileHandling.set_package_name_in_manifest(TEST_DIRECTORY, current_package_name, expected_package_name)
      new_package_name = FileHandling.get_package_name_from_manifest(TEST_DIRECTORY)
      expect(new_package_name).to eq(expected_package_name)
    end

    it "Successfully renames build.gradle" do
      current_package_name = FileHandling.get_package_name_from_gradle(TEST_DIRECTORY)
      expected_package_name = ""
      if current_package_name == RELEASE_PACKAGE_NAME
        expected_package_name = DEVELOP_PACKAGE_NAME
      elsif current_package_name == DEVELOP_PACKAGE_NAME
        expected_package_name = RELEASE_PACKAGE_NAME
      else
        # Any other name retrieved is wrong.
        expect(true).to eq(false), "The package name [#{current_package_name}] should either be release or develop"
      end

      FileHandling.set_package_name_in_gradle(TEST_DIRECTORY, current_package_name, expected_package_name)
      new_package_name = FileHandling.get_package_name_from_gradle(TEST_DIRECTORY)
      expect(new_package_name).to eq(expected_package_name)
    end

    it "Successfully renames Java codefile" do
      current_package_name = FileHandling.get_package_name_from_java_codefile(JAVA_CODEFILE_DYNAMIC_PATH)
      expected_package_name = ""
      if current_package_name == RELEASE_PACKAGE_NAME
        expected_package_name = DEVELOP_PACKAGE_NAME
      elsif current_package_name == DEVELOP_PACKAGE_NAME
        expected_package_name = RELEASE_PACKAGE_NAME
      else
        # Any other name retrieved is wrong.
        expect(true).to eq(false), "The package name [#{current_package_name}] should either be release or develop"
      end

      FileHandling.set_package_name_in_file(JAVA_CODEFILE_DYNAMIC_PATH, current_package_name, expected_package_name)
      new_package_name = FileHandling.get_package_name_from_java_codefile(JAVA_CODEFILE_DYNAMIC_PATH)
      expect(new_package_name).to eq(expected_package_name)
    end

    it "Successfully renames Kotlin codefile" do
      current_package_name = FileHandling.get_package_name_from_kotlin_codefile(KOTLIN_CODEFILE_DYNAMIC_PATH)
      expected_package_name = ""
      if current_package_name == RELEASE_PACKAGE_NAME
        expected_package_name = DEVELOP_PACKAGE_NAME
      elsif current_package_name == DEVELOP_PACKAGE_NAME
        expected_package_name = RELEASE_PACKAGE_NAME
      else
        # Any other name retrieved is wrong.
        expect(true).to eq(false), "The package name [#{current_package_name}] should either be release or develop"
      end

      FileHandling.set_package_name_in_file(KOTLIN_CODEFILE_DYNAMIC_PATH, current_package_name, expected_package_name)
      new_package_name = FileHandling.get_package_name_from_kotlin_codefile(KOTLIN_CODEFILE_DYNAMIC_PATH)
      expect(new_package_name).to eq(expected_package_name)
    end
  end
end
