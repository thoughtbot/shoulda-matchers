require 'shoulda'
require 'shoulda/controller/helpers'
require 'shoulda/controller/resource_options'
require 'shoulda/controller/macros'

module Test # :nodoc: all
  module Unit
    class TestCase
      extend Shoulda::Controller::Macros
      include Shoulda::Controller::Helpers
      Shoulda::Controller::VALID_FORMATS.each do |format|
        include "Shoulda::Controller::#{format.to_s.upcase}".constantize
      end
    end
  end
end

require 'shoulda/active_record/assertions'
require 'shoulda/action_mailer/assertions'

module ActionController #:nodoc: all
  module Integration
    class Session
      include Shoulda::Assertions
      include Shoulda::Helpers
      include Shoulda::ActiveRecord::Assertions
      include Shoulda::ActionMailer::Assertions
    end
  end
end
