# :enddoc:

if defined?(ActionController)
  require 'shoulda/action_controller'

  class ActionController::TestCase
    include Shoulda::ActionController::Matchers
    extend Shoulda::ActionController::Matchers

    def subject
      @controller
    end
  end
end

if defined?(ActionMailer)
  require 'shoulda/action_mailer'

  module Test
    module Unit
      class TestCase
        include Shoulda::ActionMailer::Matchers
        extend Shoulda::ActionMailer::Matchers
      end
    end
  end
end

if defined?(ActiveRecord)
  require 'shoulda/active_record'

  module Test
    module Unit
      class TestCase
        include Shoulda::ActiveRecord::Matchers
        extend Shoulda::ActiveRecord::Matchers
      end
    end
  end
end

