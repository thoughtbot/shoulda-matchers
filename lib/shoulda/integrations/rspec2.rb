require 'shoulda/active_record/matchers'
require 'shoulda/action_controller/matchers'
require 'shoulda/action_mailer/matchers'

# :enddoc:

module RSpec
  module Matchers
    include Shoulda::ActiveRecord::Matchers
  end

  module Rails
    module ControllerExampleGroup
      include Shoulda::ActionController::Matchers
    end

    module MailerExampleGroup
      include Shoulda::ActionMailer::Matchers
    end
  end
end

