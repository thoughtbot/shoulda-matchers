require 'shoulda'
require 'shoulda/action_controller/matchers'
require 'shoulda/action_controller/macros'

module Test # :nodoc: all
  module Unit
    class TestCase
      include Shoulda::ActionController::Matchers
      extend Shoulda::ActionController::Macros
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
