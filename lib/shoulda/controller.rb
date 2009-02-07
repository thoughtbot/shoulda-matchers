require 'shoulda'
require 'shoulda/controller/helpers'
require 'shoulda/controller/matchers'
require 'shoulda/controller/macros'

module Test # :nodoc: all
  module Unit
    class TestCase
      include Shoulda::Controller::Matchers
      include Shoulda::Controller::Helpers
      extend Shoulda::Controller::Macros
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
