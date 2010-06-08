require 'shoulda/active_record/matchers'
require 'shoulda/action_controller/matchers'
require 'shoulda/action_mailer/matchers'
require 'active_support/test_case'

# :enddoc:
module ActiveSupport
  class TestCase
    include Shoulda::ActiveRecord::Matchers
    include Shoulda::ActionController::Matchers
    include Shoulda::ActionMailer::Matchers
  end
end
