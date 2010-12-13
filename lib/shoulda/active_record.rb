require 'shoulda'
require 'shoulda/active_record/helpers'
require 'shoulda/active_record/matchers'

module Test # :nodoc: all
  module Unit
    class TestCase
      include Shoulda::ActiveRecord::Matchers
      extend Shoulda::ActiveRecord::Matchers
    end
  end
end
