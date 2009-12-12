# Specifies gem version of Rails to use when vendor/rails is not present
old_verbose, $VERBOSE = $VERBOSE, nil
RAILS_GEM_VERSION = '>= 2.3.2' unless defined? RAILS_GEM_VERSION
$VERBOSE = old_verbose

require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.log_level = :debug
  config.cache_classes = false
  config.whiny_nils = true
  config.action_controller.session = {
    :key    => 'shoulda_session',
    :secret => 'ceae6058a816b1446e09ce90d8372511'
  }
end

# Dependencies.log_activity = true
