module Shoulda # :nodoc:
  module Matchers
    module ActiveRecord # :nodoc:

      # Ensure that the attribute's value is in the range specified
      #
      # Options:
      # * <tt>in</tt> - the set of allows values for this attribute
      # * <tt>with_low_message</tt> - value the test expects to find in
      #   <tt>errors.on(:attribute)</tt>. Regexp or string. Defaults to the
      #   translation for :inclusion.
      # * <tt>with_high_message</tt> - value the test expects to find in
      #   <tt>errors.on(:attribute)</tt>. Regexp or string. Defaults to the
      #   translation for :inclusion.
      #
      # Example:
      #   it { should ensure_inclusion_of(:age).in_range(0..100) }
      #
      def ensure_inclusion_of(attr)
        EnsureInclusionOfMatcher.new(attr)
      end

      class EnsureInclusionOfMatcher < ValidationMatcher # :nodoc:

        def in(enum)
          @enum = enum
          self
        end

        def with_message(message)
          if message
            if @enum.kind_of? Range
              @low_message = message
              @high_message = message
            else
              @message = message
            end
          end
          self
        end

        def with_low_message(message)
          @low_message = message if message
          self
        end

        def with_high_message(message)
          @high_message = message if message
          self
        end

        def description
          "ensure inclusion of #{@attribute} in #{ @enum.inspect }"
        end

        def matches?(subject)
          super(subject)

          if @enum.kind_of?(Range)
            @low_message  ||= :inclusion
            @high_message ||= :inclusion

            disallows_lower_value &&
              allows_minimum_value &&
              disallows_higher_value &&
              allows_maximum_value
          else
            @message      ||= :inclusion

            allows_correct_value &&
             disallows_incorrect_value
          end
        end

        private

        def disallows_lower_value
          @enum.min == 0 || disallows_value_of(@enum.min - 1, @low_message)
        end

        def disallows_higher_value
          disallows_value_of(@enum.max + 1, @high_message)
        end

        def allows_minimum_value
          allows_value_of(@enum.min, @low_message)
        end

        def allows_maximum_value
          allows_value_of(@enum.max, @high_message)
        end

        def allows_correct_value
          allows_value_of(@enum.first, @message)
        end

        def disallows_incorrect_value
          disallows_value_of(Object.new, @message)
        end
      end
    end
  end
end
