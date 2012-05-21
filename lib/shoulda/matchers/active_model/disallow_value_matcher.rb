require 'forwardable'
module Shoulda # :nodoc:
  module Matchers
    module ActiveModel # :nodoc:
      class DisallowValueMatcher # :nodoc:
        extend Forwardable
        def_delegators :@allow_matcher,:for, :with_message, :failure_message,
          :negative_failure_message, :description

        def initialize(*values)
          @allow_matcher = AllowValueMatcher.new(values)
        end

        def matches?(instance)
          ! @allow_matcher.matches?
        end
      end
    end
  end
end
