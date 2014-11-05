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

    def wrap(path)
      if path.is_a?(Pathname)
        path
      else
        find_in_project(path)
      end
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
      pathname = wrap(path)
      create_parents_of(pathname)
      pathname.open('w') { |f| f.write(content) }
    end

    def create_parents_of(path)
      wrap(path).dirname.mkpath
    end

    def append_to_file(path, content, options = {})
      create_parents_of(path)
      open(path, 'a') { |f| f.puts(content + "\n") }
    end

    def remove_from_file(path, pattern)
      content = read(path)
      content.sub!(/#{pattern}\n/, '')
      write(path, content)
    end
  end
end
