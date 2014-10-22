require 'forwardable'

require File.expand_path('../warnings_spy/filesystem', __FILE__)
require File.expand_path('../warnings_spy/reader', __FILE__)
require File.expand_path('../warnings_spy/partitioner', __FILE__)
require File.expand_path('../warnings_spy/reporter', __FILE__)

class WarningsSpy
  extend Forwardable

  def initialize(project_name)
    filesystem = Filesystem.new
    @warnings_file = filesystem.warnings_file
    @reader = Reader.new(filesystem)
    @partitioner = Partitioner.new(reader, filesystem)
    @reporter = Reporter.new(partitioner, filesystem, project_name)
  end

  def capture_warnings
    $stderr.reopen(warnings_file.path)
  end

  def report_warnings_at_exit
    at_exit do
      printing_exceptions do
        report_and_exit
      end
    end
  end

  protected

  attr_reader :warnings_file, :reader, :partitioner, :reporter

  private

  def_delegators :partitioner, :relevant_warning_groups,
    :irrelevant_warning_groups

  def report_and_exit
    reader.read
    partitioner.partition
    reporter.report
    fail_build_if_there_are_any_warnings
  end

  def fail_build_if_there_are_any_warnings
    if relevant_warning_groups.any?
      exit(1)
    end
  end

  def printing_exceptions
    begin
      yield
    rescue => error
      puts "\n--- ERROR IN AT_EXIT --------------------------------"
      puts "#{error.class}: #{error.message}"
      puts error.backtrace.join("\n")
      puts "-----------------------------------------------------"
      raise error
    end
  end
end
