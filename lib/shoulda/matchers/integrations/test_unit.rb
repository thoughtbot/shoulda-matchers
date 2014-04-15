# :enddoc:
require 'shoulda/matchers/integrations/nunit_test_case_detection'

Shoulda::Matchers.nunit_test_case_constants.each do |constant|
  constant.class_eval do
    include Shoulda::Matchers::Independent
    extend Shoulda::Matchers::Independent
  end
end

if defined?(ActionController::TestCase)
  ActionController::TestCase.class_eval do
    include Shoulda::Matchers::ActionController
    extend Shoulda::Matchers::ActionController

    def subject
      @controller
    end
  end
end

if defined?(ActiveSupport::TestCase)
  ActiveSupport::TestCase.class_eval do
    if defined?(Shoulda::Matchers::ActiveRecord)
      include Shoulda::Matchers::ActiveRecord
      extend Shoulda::Matchers::ActiveRecord
    end

    if defined?(Shoulda::Matchers::ActiveModel)
      include Shoulda::Matchers::ActiveModel
      extend Shoulda::Matchers::ActiveModel
    end
  end
end
