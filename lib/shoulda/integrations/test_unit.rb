# :enddoc:

if defined?(ActionController)
  require 'shoulda/action_controller'

  class ActionController::TestCase
    include Shoulda::ActionController
    extend Shoulda::ActionController

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
        include Shoulda::ActionMailer
        extend Shoulda::ActionMailer
      end
    end
  end
end

if defined?(ActiveRecord)
  require 'shoulda/active_record'

  module Test
    module Unit
      class TestCase
        include Shoulda::ActiveRecord
        extend Shoulda::ActiveRecord
      end
    end
  end
end

