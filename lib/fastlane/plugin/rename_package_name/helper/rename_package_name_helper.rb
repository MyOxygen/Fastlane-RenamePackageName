class Nonsense
    def self.rename_package_names(project_home_path, new_package_name, profiles, language="java")
        # First check the parameters
        if project_home_path == nil || project_home_path == "" || project_home_path.strip! != nil
            raise "Invalid project home path: [" + project_home_path + "]"
        end

        path = project_home_path
        if !path.end_with? "/"
            path = path + "/"
        end
        gradle_directory = path + "app/"
        fastlane_directory = path + "fastlane/"
        source_directory = gradle_directory + "src/"

        if new_package_name == nil || new_package_name == "" || new_package_name.strip! != nil
            raise "Invalid package name: [" + new_package_name + "]"
        end

        if profiles == nil || profiles.length == 0
            raise "Invalid profiles"
        end

        if language.downcase != "java" && language.downcase != "kotlin"
            raise "Invalid programming language: [" + language + "]"
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
            old_package_name = get_package_name_from_manifest(path)
            if (old_package_name != new_package_name)
                # We need to updated the package name to the new package name.
                set_package_name_in_manifest(path, old_package_name, new_package_name)
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
        gradle_package_name = get_package_name_from_gradle(gradle_directory)
        if gradle_package_name != new_package_name
            set_package_name_in_gradle(gradle_directory, gradle_package_name, new_package_name)
        end

        # 4. Update the Appfile (part of the Fastlane package)
        appfile_package_name = get_package_name_from_appfile(fastlane_directory)
        if appfile_package_name != new_package_name
            set_package_name_in_appfile(fastlane_directory, appfile_package_name, new_package_name)
        end
    end

    # --------------------
    # Private functions
    # --------------------

    private

    def self.get_package_name_from_manifest(directory)
        manifest_path = directory + "AndroidManifest.xml"
        package_name = get_package_name_from_file(manifest_path, /package=\"/, 9)
        return package_name
    end

    def self.set_package_name_in_manifest(directory, old_package_name, new_package_name)
        manifest_path = directory + "AndroidManifest.xml"
        set_package_name_in_file(manifest_path, old_package_name, new_package_name)
    end

    def self.get_package_name_from_gradle(directory)
        gradle_path = directory + "build.gradle"
        package_name = get_package_name_from_file(gradle_path, /applicationId \"/, 15)
        return package_name
    end

    def self.set_package_name_in_gradle(directory, old_package_name, new_package_name)
        gradle_path = directory + "build.gradle"
        set_package_name_in_file(gradle_path, old_package_name, new_package_name)
    end

    def self.get_package_name_from_appfile(directory)
        appfile_path = directory + "Appfile"
        package_name = get_package_name_from_file(appfile_path, /package_name\(\"/, 14)
        return package_name
    end

    def self.set_package_name_in_appfile(directory, old_package_name, new_package_name)
        appfile_path = directory + "Appfile"
        set_package_name_in_file(appfile_path, old_package_name, new_package_name)
    end

    def self.get_package_name_from_file(file_path, attribute_regex, attribute_regex_length)
        package_name = ""
        # Read/write file - https://www.rubyguides.com/2015/05/working-with-files-ruby/#How_to_Read_Files_In_Ruby
        File.foreach(file_path) do |line|
            # RegEx - http://rubylearning.com/satishtalim/ruby_regular_expressions.html
            # String manipulation - https://ruby-doc.org/core-3.0.0/String.html
            index_of_package_attribute = line =~ attribute_regex
            if index_of_package_attribute
                # Retrieve package name
                attribute_removed = line[index_of_package_attribute + attribute_regex_length, 1000] # Use large number for end of string
                index_of_quote = attribute_removed =~ /\"/

                package_name = attribute_removed[0, index_of_quote]
                break 
            end
        end
        
        return package_name
    end

    def self.set_package_name_in_file(file_path, old_package_name, new_package_name)
        # Read/write file - https://www.rubyguides.com/2015/05/working-with-files-ruby/#How_to_Read_Files_In_Ruby
        file_data = File.read(file_path)
        # Replace package name
        new_file_data = file_data.gsub(old_package_name, new_package_name)
        File.write(file_path, new_file_data)
    end
end