require 'shoulda/controller/helpers'
require 'shoulda/controller/resource_options'
require 'shoulda/controller/macros'

module Test # :nodoc: all
  module Unit
    class TestCase
      extend ThoughtBot::Shoulda::Controller::Macros
      include ThoughtBot::Shoulda::Controller::Helpers
      ThoughtBot::Shoulda::Controller::VALID_FORMATS.each do |format|
        include "ThoughtBot::Shoulda::Controller::#{format.to_s.upcase}".constantize
      end
    end
  end
end
