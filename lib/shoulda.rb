require 'shoulda/context'
require 'shoulda/proc_extensions'
require 'shoulda/assertions'
require 'shoulda/macros'
require 'shoulda/helpers'
require 'shoulda/rails' if defined? RAILS_ROOT

module Test # :nodoc: all
  module Unit
    class TestCase
      extend Shoulda
      include Shoulda::Assertions
      extend Shoulda::Macros
      include Shoulda::Helpers
    end
  end
end
