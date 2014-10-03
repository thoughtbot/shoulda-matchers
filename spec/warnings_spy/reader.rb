class WarningsSpy
  class Reader
    attr_reader :warning_groups

    def initialize(filesystem)
      @warnings_file = filesystem.warnings_file

      @recording = false
      @current_group = []
      @warning_groups = []
    end

    def read
      warnings_file.rewind

      warnings_file.each_line do |line|
        process_line(line)
      end

      add_group(current_group)
    end

    protected

    attr_reader :warnings_file, :current_group

    private

    def process_line(line)
      if backtrace_line?(line)
        unless recording?
          start_of_error = find_start_of_error

          if start_of_error
            _, start_of_error_index = start_of_error
            @current_group = current_group[start_of_error_index..-1]
          end

          @recording = true
        end
      else
        if recording?
          add_group(current_group)
          current_group.clear
        end

        @recording = false
      end

      current_group << line
    end

    def find_start_of_error
      current_group.each_with_index.to_a.reverse.detect do |line, _|
        start_of_error?(line)
      end
    end

    def start_of_error?(line)
      line =~ /^.+?:\d+:in `[^']+':/
    end

    def add_group(group)
      unless group.empty? || group_already_added?(group)
        warning_groups << group
      end
    end

    def group_already_added?(group_to_be_added)
      warning_groups.any? do |group|
        group == group_to_be_added
      end
    end

    def backtrace_line?(line)
      line =~ /^\s+/
    end

    def recording?
      @recording
    end
  end
end
