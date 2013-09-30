if defined?(ActionController) && defined?(ActionController::TestCase)
  require 'shoulda/matchers/action_controller'

  ActionController::TestCase.class_eval do
    include Shoulda::Matchers::ActionController
    extend Shoulda::Matchers::ActionController

    def subject
      @controller
    end
  end
end

if defined?(ActiveRecord) && defined?(ActiveSupport::TestCase)
  require 'shoulda/matchers/active_record'

  ActiveSupport::TestCase.class_eval do
    include Shoulda::Matchers::ActiveRecord
    extend Shoulda::Matchers::ActiveRecord
  end
end

if defined?(ActiveModel) && defined?(ActiveSupport::TestCase)
  require 'shoulda/matchers/active_model'

  ActiveSupport::TestCase.class_eval do
    include Shoulda::Matchers::ActiveModel
    extend Shoulda::Matchers::ActiveModel
  end
end
