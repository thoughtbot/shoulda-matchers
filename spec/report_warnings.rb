require 'warnings_logger'

WarningsLogger.configure do |config|
  config.project_name = 'shoulda-matchers'
  config.project_directory = Pathname.new('..').expand_path(__dir__)
end

WarningsLogger.enable
