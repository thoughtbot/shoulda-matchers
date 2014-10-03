require 'forwardable'

class WarningsSpy
  class Reporter
    extend Forwardable

    def initialize(partitioner, filesystem, project_name)
      @partitioner = partitioner
      @warnings_file = filesystem.warnings_file
      @relevant_warnings_file = filesystem.relevant_warnings_file
      @irrelevant_warnings_file = filesystem.irrelevant_warnings_file
      @project_name = project_name
    end

    def report
      reporting_all_groups do
        report_relevant_warning_groups
        report_irrelevant_warning_groups
      end
    end

    protected

    attr_reader :partitioner, :warnings_file, :relevant_warnings_file,
      :irrelevant_warnings_file, :project_name

    private

    def_delegators :partitioner, :relevant_warning_groups,
      :irrelevant_warning_groups

    def report_relevant_warning_groups
      if relevant_warning_groups.any?
        print_divider('-', 75, header: " #{project_name} warnings:")
        relevant_warning_groups.each do |group|
          group.each do |line|
            relevant_warnings_file.puts(line)
            puts line
          end
        end
        print_divider('-', 75)
        puts "#{project_name} warnings written to #{relevant_warnings_file.path}."
      end
    end

    def report_irrelevant_warning_groups
      if irrelevant_warning_groups.any?
        irrelevant_warning_groups.each do |group|
          group.each do |line|
            irrelevant_warnings_file.puts(line)
          end
        end
        puts "Non #{project_name} warnings were raised during the test run. These have been written to #{irrelevant_warnings_file.path}."
      end
    end

    def reporting_all_groups
      if relevant_warning_groups.any? || irrelevant_warning_groups.any?
        puts
        yield
        puts "All warnings were written to #{warnings_file.path}."
        puts
      end
    end

    def print_divider(character, count, options = {})
      puts

      if options[:header]
        first_count = 10
        second_count = options[:header].length - first_count
        string =
          horizontal_rule(character, first_count) +
          options[:header] +
          horizontal_rule(character, second_count)
        puts string
      else
        puts horizontal_rule(character, count)
      end

      puts
    end

    def horizontal_rule(character, count)
      character * count
    end
  end
end
