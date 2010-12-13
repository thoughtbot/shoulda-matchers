require 'test/unit'

require 'shoulda/context'
require 'shoulda/proc_extensions'
require 'shoulda/assertions'
require 'shoulda/autoload_macros'
require 'shoulda/rails' if defined? RAILS_ROOT

module Test # :nodoc: all
  module Unit
    class TestCase
      include Shoulda::InstanceMethods
      extend Shoulda::ClassMethods
      include Shoulda::Assertions
    end
  end
end

