require 'fileutils'

module Tests
  class Filesystem
    PROJECT_NAME = 'test-project'
    ROOT_DIRECTORY = Pathname.new('../../../..').expand_path(__FILE__)
    TEMP_DIRECTORY = ROOT_DIRECTORY.join('tmp/acceptance')
    PROJECT_DIRECTORY = TEMP_DIRECTORY.join(PROJECT_NAME)

    def root_directory
      ROOT_DIRECTORY
    end

    def temp_directory
      TEMP_DIRECTORY
    end

    def project_directory
      PROJECT_DIRECTORY
    end

    def within_project(&block)
      Dir.chdir(project_directory, &block)
    end

    def clean
      if temp_directory.exist?
        temp_directory.rmtree
      end
    end

    def create
      project_directory.mkpath
    end

    def find_in_project(path)
      project_directory.join(path)
    end

    def open(path, *args, &block)
      find_in_project(path).open(*args, &block)
    end

    def read(path)
      find_in_project(path).read
    end

    def write(path, content)
      pathname = find_in_project(path)
      pathname.dirname.mkpath
      pathname.open('w') { |f| f.write(content) }
    end

    def append_to_file(path, content, options = {})
      if options[:following]
        append_to_file_following(path, content, options[:following])
      else
        open(path, 'a') { |f| f.puts(content + "\n") }
      end
    end

    def append_to_file_following(path, content_to_add, insertion_point)
      content_to_add = content_to_add + "\n"

      file_content = read(path)
      file_lines = file_content.split("\n")
      insertion_index = file_lines.find_index(insertion_point)

      if insertion_index.nil?
        raise "Cannot find #{insertion_point.inspect} in #{path}"
      end

      file_lines.insert(insertion_index + 1, content_to_add)
      new_file_content = file_lines.join("\n")
      write(path, new_file_content)
    end

    def remove_from_file(path, pattern)
      content = read(path)
      content.sub!(/#{pattern}\n/, '')
      write(path, content)
    end
  end
end
