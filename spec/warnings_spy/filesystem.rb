require 'fileutils'

class WarningsSpy
  class Filesystem
    PROJECT_DIR = File.expand_path('../../..', __FILE__)
    TEMP_DIR = File.join(PROJECT_DIR, 'tmp')

    def initialize
      @files_by_name = Hash.new do |hash, name|
        FileUtils.mkdir_p(TEMP_DIR)
        hash[name] = file_for(name)
      end
    end

    def warnings_file
      files_by_name['all_warnings']
    end

    def irrelevant_warnings_file
      files_by_name['irrelevant_warnings']
    end

    def relevant_warnings_file
      files_by_name['relevant_warnings']
    end

    def project_dir
      PROJECT_DIR
    end

    protected

    attr_reader :files_by_name

    private

    def path_for(name)
      File.join(TEMP_DIR, "#{name}.txt")
    end

    def file_for(name)
      File.open(path_for(name), 'w+')
    end
  end
end
