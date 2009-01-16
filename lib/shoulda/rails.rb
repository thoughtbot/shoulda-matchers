require 'rubygems'
require 'active_support'
require 'shoulda'

require 'shoulda/active_record' if defined? ActiveRecord::Base
require 'shoulda/controller'    if defined? ActionController::Base
require 'shoulda/action_mailer' if defined? ActionMailer::Base

if defined?(RAILS_ROOT)
  # load in the 3rd party macros from vendorized plugins and gems
  Shoulda.autoload_macros RAILS_ROOT, File.join("vendor", "{plugins,gems}", "*")
end
