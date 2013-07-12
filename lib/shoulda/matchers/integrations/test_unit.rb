if defined?(ActionController)
  require 'shoulda/matchers/action_controller'

  ActionController::TestCase.class_eval do
    include Shoulda::Matchers::ActionController
    extend Shoulda::Matchers::ActionController

    def subject
      @controller
    end
  end
end

if defined?(ActiveRecord)
  require 'shoulda/matchers/active_record'

  ActiveSupport::TestCase.class_eval do
    include Shoulda::Matchers::ActiveRecord
    extend Shoulda::Matchers::ActiveRecord
  end
end

if defined?(ActiveModel)
  require 'shoulda/matchers/active_model'

  ActiveSupport::TestCase.class_eval do
    include Shoulda::Matchers::ActiveModel
    extend Shoulda::Matchers::ActiveModel
  end
end
