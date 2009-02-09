require 'shoulda'
require 'shoulda/action_view/macros'

module Test # :nodoc: all
  module Unit
    class TestCase
      extend Shoulda::ActionView::Macros
    end
  end
end
