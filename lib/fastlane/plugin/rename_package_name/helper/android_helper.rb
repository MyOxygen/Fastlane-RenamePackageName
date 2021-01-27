require_relative "./file_handling.rb"
require_relative "./generic_helper.rb"

class Android
    def self.rename_package_names(project_home_path, new_package_name, profiles, language = "java")
        # First check the parameters
        if GenericHelper.is_nil_or_whitespace(project_home_path)
            FastlaneCore::UI.user_error!("Invalid project home path: [" + project_home_path + "]")
            return
        end

        path = project_home_path
        if !path.end_with? "/"
            path = path + "/"
        end
        gradle_directory = path + "app/"
        fastlane_directory = path + "fastlane/"
        source_directory = gradle_directory + "src/"

        if GenericHelper.is_nil_or_whitespace(new_package_name)
            FastlaneCore::UI.user_error!("Invalid package name: [" + new_package_name + "]")
            return
        end

        if GenericHelper.is_nil_or_empty(profiles)
            FastlaneCore::UI.user_error!("Invalid profiles")
            return
        end

        if GenericHelper.is_nil_or_whitespace(language) || (language.downcase != "java" && language.downcase != "kotlin")
            FastlaneCore::UI.user_error!("Invalid programming language: [" + language + "]")
            return
        end

        code_path = source_directory + "main/" + language.downcase + "/"
        code_directory_new = code_path + new_package_name.gsub(".", "/") + "/"
        
        # 1. Determine if we need to change the package name throughout the
        #    Android project.
        profile_directories = []
        profiles.each do |profile|
            profile_directories.push(profile + "/")
        end

        old_package_name = ""
        profile_directories.each do |profile_directory|
            # For each profile, update the package name in the manifest.
            path = source_directory + profile_directory
            old_package_name = FileHandling.get_package_name_from_manifest(path)
            if (old_package_name != new_package_name)
                # We need to updated the package name to the new package name.
                FileHandling.set_package_name_in_manifest(path, old_package_name, new_package_name)
            end
        end

        # 2. Check if we need to move the necessary files into the new package-
        #    name-driven folder structure, AND that the package reference is 
        #    updated in both Java and Kotlin code files.
        # TODO: This doesn't seem to move the files if the new directory exists. Why?
        code_directory_old = code_path + old_package_name.gsub(".", "/") + "/" # Use the package name obtained from previous step
        if !Dir.exist?(code_directory_new) || Dir.empty?(code_directory_new) 
            # Create the new folder if it doesn't already exist.
            FileUtils.mkdir_p(code_directory_new)

            # When moving files, assume the previous directory is that of the release
            # package name structure.
            Dir.entries(code_directory_old).each do |file|
                file_path = code_directory_old + file
                # TODO: Apply this `if` block to nested folders and code files.
                if file != "." && file != ".." && File.exist?(file_path) && !File.directory?(file_path)
                    # Update the package reference to the new name
                    file_data = File.read(file_path)
                    new_file_data = file_data.gsub(old_package_name, new_package_name)
                    File.write(file_path, new_file_data)

                    # Move files - https://ruby-doc.org/stdlib-2.4.1/libdoc/fileutils/rdoc/FileUtils.html#method-c-mv
                    FileUtils.mv(file_path, code_directory_new + file, force: true)
                end
            end
        end

        # 3. Check if the package name needs changing in the app/build.gradle file.
        gradle_package_name = FileHandling.get_package_name_from_gradle(gradle_directory)
        if gradle_package_name != new_package_name
            FileHandling.set_package_name_in_gradle(gradle_directory, gradle_package_name, new_package_name)
        end

        # 4. Update the Appfile (part of the Fastlane package)
        appfile_package_name = FileHandling.get_package_name_from_appfile(fastlane_directory)
        if appfile_package_name != new_package_name
            FileHandling.set_package_name_in_appfile(fastlane_directory, appfile_package_name, new_package_name)
        end
    end
end