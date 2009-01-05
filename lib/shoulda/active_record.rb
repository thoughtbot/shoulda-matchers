require 'shoulda'
require 'shoulda/active_record/assertions'
require 'shoulda/active_record/macros'

module Test # :nodoc: all
  module Unit
    class TestCase
      include Shoulda::ActiveRecord::Assertions
      extend Shoulda::ActiveRecord::Macros
    end
  end
end
