require 'shoulda'
require 'shoulda/action_controller/matchers'

module Test # :nodoc: all
  module Unit
    class TestCase
      include Shoulda::ActionController::Matchers
      extend Shoulda::ActionController::Matchers
    end
  end
end

if defined?(ActionController::TestCase)
  class ActionController::TestCase
    def subject
      @controller
    end
  end
end
