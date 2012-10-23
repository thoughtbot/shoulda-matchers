# :enddoc:
require 'test/unit/testcase'
require 'shoulda/matchers/independent'

module Test
  module Unit
    class TestCase
      include Shoulda::Matchers::Independent
      extend Shoulda::Matchers::Independent
    end
  end
end

if defined?(ActionController)
  require 'shoulda/matchers/action_controller'

  class ActionController::TestCase
    include Shoulda::Matchers::ActionController
    extend Shoulda::Matchers::ActionController

    def subject
      @controller
    end
  end
end

if defined?(ActionMailer)
  require 'shoulda/matchers/action_mailer'

  module Test
    module Unit
      class TestCase
        include Shoulda::Matchers::ActionMailer
        extend Shoulda::Matchers::ActionMailer
      end
    end
  end
end

if defined?(ActiveRecord)
  require 'shoulda/matchers/active_record'
  require 'shoulda/matchers/active_model'

  module Test
    module Unit
      class TestCase
        include Shoulda::Matchers::ActiveRecord
        extend Shoulda::Matchers::ActiveRecord
        include Shoulda::Matchers::ActiveModel
        extend Shoulda::Matchers::ActiveModel
      end
    end
  end
elsif defined?(ActiveModel)
  require 'shoulda/matchers/active_model'

  module Test
    module Unit
      class TestCase
        include Shoulda::Matchers::ActiveModel
        extend Shoulda::Matchers::ActiveModel
      end
    end
  end
end
