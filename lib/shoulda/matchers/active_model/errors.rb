module Shoulda # :nodoc:
  module Matchers
    module ActiveModel # :nodoc:
      class CouldNotDetermineValueOutsideOfArray < RuntimeError; end
      class NonNullableBooleanError < Shoulda::Matchers::Error; end
    end
  end
end
