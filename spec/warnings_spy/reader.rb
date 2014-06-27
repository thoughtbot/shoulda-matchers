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
      if backtrace_line?(line) && recording?
        current_group << line
      else
        unless current_group.empty?
          add_group(current_group)
          current_group.clear
        end

        current_group << line

        @recording = true
      end
    end

    def add_group(group)
      unless group_already_added?(group)
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
