class FileHandling
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