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
        warning_groups.partition do |group|
          group.any? { |line| line.include?(search_text) }
        end
    end

    protected

    attr_reader :reader, :search_text

    private

    def_delegators :reader, :warning_groups
  end
end
