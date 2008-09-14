require 'shoulda'
require 'shoulda/controller/routing/macros'

module Test # :nodoc: all
  module Unit
    class TestCase
      extend ThoughtBot::Shoulda::Controller::Routing::Macros
    end
  end
end
