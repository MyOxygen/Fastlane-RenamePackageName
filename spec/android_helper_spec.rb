describe AndroidHelper do
  private
  STATIC_FILES = "./spec/test_files/static_files/"
  private
  RELEASE_PACKAGE_NAME = "com.example.app"
  private
  DEVELOP_PACKAGE_NAME = "com.example.app.develop"

  private
  INVALID_STRINGS = [nil, "", "   "]
  private
  INVALID_ARRAYS = [nil, []]

  private
  INVALID_PATHS = INVALID_STRINGS
  private
  VALID_PATH_NO_FILES = "./"
  private
  ANDROID_PROJECT_PATH = "./spec/test_files/android_src/"
  private
  SOURCE_DIRECTORY = "#{ANDROID_PROJECT_PATH}app/src/"
  private
  JAVA_CODE_PATH = "#{SOURCE_DIRECTORY}main/java/com/example/app/"
  private
  KOTLIN_CODE_PATH = "#{SOURCE_DIRECTORY}main/kotlin/com/example/app/"
  private
  JAVA_FILENAME = "MainApplication.java"
  private
  KOTLIN_FILENAME = "MainActivity.kt"

  private
  INVALID_PACKAGE_NAMES = INVALID_STRINGS
  private
  VALID_PACKAGE_NAME = RELEASE_PACKAGE_NAME

  private
  INVALID_PROFILES = INVALID_ARRAYS
  private
  VALID_PROFILES = ["debug", "main"]

  private
  INVALID_LANGUAGES = INVALID_STRINGS + ["javascript", "jar", "kot", "aaaaa"]
  private
  VALID_LANGUAGES = ["java", "kotlin", "JAVA", "KOTLIN"]

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
        AndroidHelper.rename_package_names(
          invalid_path,
          VALID_PACKAGE_NAME,
          VALID_PROFILES
        )
      end
    end

    it "Invalid package name" do
      INVALID_PACKAGE_NAMES.each do |invalid_package_name|
        expect(Fastlane::UI).to receive(:user_error!)
        AndroidHelper.rename_package_names(
          ANDROID_PROJECT_PATH,
          invalid_package_name,
          VALID_PROFILES
        )
      end
    end

    it "Invalid profiles" do
      INVALID_PROFILES.each do |invalid_profile_list|
        expect(Fastlane::UI).to receive(:user_error!)
        AndroidHelper.rename_package_names(
          ANDROID_PROJECT_PATH,
          VALID_PACKAGE_NAME,
          invalid_profile_list
        )
      end
    end

    it "Invalid languages" do
      invalid_languages = INVALID_LANGUAGES + []
      INVALID_PROFILES.each do |invalid_profile_list|
        expect(Fastlane::UI).to receive(:user_error!)
        AndroidHelper.rename_package_names(
          ANDROID_PROJECT_PATH,
          VALID_PACKAGE_NAME,
          invalid_profile_list
        )
      end
    end
  end

  context "Displays user error when path is not found" do
    it "Valid path, but does not exist" do
      expect(Fastlane::UI).to receive(:user_error!)
      AndroidHelper.rename_package_names(
        VALID_PATH_NO_FILES, # Valid path, but no valid files in this directory
        VALID_PACKAGE_NAME,
        VALID_PROFILES
      )
    end
  end

  context "Files update successfully" do
    it "AndroidManifest" do
      AndroidHelper.update_manifests(
        SOURCE_DIRECTORY,
        VALID_PROFILES,
        DEVELOP_PACKAGE_NAME
      )
      VALID_PROFILES.each do |profile|
        package_name = FileHandling.get_package_name_from_manifest(SOURCE_DIRECTORY + "#{profile}/")
        expect(package_name).to eq(DEVELOP_PACKAGE_NAME)
      end
    end

    it "build.gradle" do
      gradle_directory = ANDROID_PROJECT_PATH + "app/"
      AndroidHelper.update_gradle(
        gradle_directory,
        DEVELOP_PACKAGE_NAME
      )
      package_name = FileHandling.get_package_name_from_gradle(gradle_directory)
      expect(package_name).to eq(DEVELOP_PACKAGE_NAME)
    end

    it "MainActivity.kt" do
      kotlin_file = KOTLIN_CODE_PATH + KOTLIN_FILENAME
      old_package_name = FileHandling.get_package_name_from_kotlin_codefile(kotlin_file)
      AndroidHelper.rename_package_in_code_file(
        kotlin_file,
        old_package_name,
        DEVELOP_PACKAGE_NAME
      )
      package_name = FileHandling.get_package_name_from_kotlin_codefile(kotlin_file)
      expect(package_name).to eq(DEVELOP_PACKAGE_NAME)
    end

    it "MainApplication.java" do
      java_file = JAVA_CODE_PATH + JAVA_FILENAME
      old_package_name = FileHandling.get_package_name_from_java_codefile(java_file)
      AndroidHelper.rename_package_in_code_file(
        java_file,
        old_package_name,
        DEVELOP_PACKAGE_NAME
      )
      package_name = FileHandling.get_package_name_from_java_codefile(java_file)
      expect(package_name).to eq(DEVELOP_PACKAGE_NAME)
    end
  end

  context "Files moved successfully" do
    it "Java files" do
      AndroidHelper.move_code_files(SOURCE_DIRECTORY, "java", RELEASE_PACKAGE_NAME, DEVELOP_PACKAGE_NAME)
      expect(Dir.exist?("#{JAVA_CODE_PATH}develop")).to eq(true)
      expect(Dir.empty?("#{JAVA_CODE_PATH}develop")).to eq(false)
      expect(File.exist?("#{JAVA_CODE_PATH}#{JAVA_FILENAME}")).to eq(false)
      expect(File.exist?("#{JAVA_CODE_PATH}develop/#{JAVA_FILENAME}")).to eq(true)

      package_name = FileHandling.get_package_name_from_java_codefile("#{JAVA_CODE_PATH}develop/#{JAVA_FILENAME}")
      expect(package_name).to eq(DEVELOP_PACKAGE_NAME)
    end

    it "Kotlin files" do
      AndroidHelper.move_code_files(SOURCE_DIRECTORY, "kotlin", RELEASE_PACKAGE_NAME, DEVELOP_PACKAGE_NAME)
      expect(Dir.exist?("#{KOTLIN_CODE_PATH}develop")).to eq(true)
      expect(Dir.empty?("#{KOTLIN_CODE_PATH}develop")).to eq(false)
      expect(File.exist?("#{KOTLIN_CODE_PATH}#{KOTLIN_FILENAME}")).to eq(false)
      expect(File.exist?("#{KOTLIN_CODE_PATH}develop/#{KOTLIN_FILENAME}")).to eq(true)

      package_name = FileHandling.get_package_name_from_kotlin_codefile("#{KOTLIN_CODE_PATH}develop/#{KOTLIN_FILENAME}")
      expect(package_name).to eq(DEVELOP_PACKAGE_NAME)
    end

    it "Same files are not moved" do
      AndroidHelper.move_code_files(SOURCE_DIRECTORY, "kotlin", RELEASE_PACKAGE_NAME, RELEASE_PACKAGE_NAME)
      expect(Dir.exist?("#{KOTLIN_CODE_PATH}develop")).to eq(false)
      expect(Dir.empty?(KOTLIN_CODE_PATH)).to eq(false)
      expect(File.exist?("#{KOTLIN_CODE_PATH}#{KOTLIN_FILENAME}")).to eq(true)

      package_name = FileHandling.get_package_name_from_kotlin_codefile("#{KOTLIN_CODE_PATH}/#{KOTLIN_FILENAME}")
      expect(package_name).to eq(RELEASE_PACKAGE_NAME)
    end
  end
end
