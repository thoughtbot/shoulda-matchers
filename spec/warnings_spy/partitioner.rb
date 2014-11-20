require 'forwardable'

class WarningsSpy
  class Partitioner
    extend Forwardable

    attr_reader :relevant_warning_groups, :irrelevant_warning_groups

    def initialize(reader, filesystem)
      @reader = reader
      @search_text = filesystem.project_dir
    end

    def partition
      @relevant_warning_groups, @irrelevant_warning_groups =
        warning_groups.partition { |group| relevant_warnings?(group) }
    end

    protected

    attr_reader :reader, :search_text

    private

    def_delegators :reader, :warning_groups

    def relevant_warnings?(group)
      first_line = group[0]
      first_line.start_with?("#{project_root}/lib")
    end

    def project_root
      File.expand_path('../../..')
    end
  end
end
