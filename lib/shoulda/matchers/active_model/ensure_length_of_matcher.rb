module Shoulda # :nodoc:
  module Matchers
    module ActiveModel # :nodoc:

      # Ensures that the length of the attribute is validated. Only works with
      # string/text columns because it uses a string to check length.
      #
      # Options:
      # * <tt>is_at_least</tt> - minimum length of this attribute
      # * <tt>is_at_most</tt> - maximum length of this attribute
      # * <tt>is_equal_to</tt> - exact requred length of this attribute
      # * <tt>with_short_message</tt> - value the test expects to find in
      #   <tt>errors.on(:attribute)</tt>. Regexp or string.  Defaults to the
      #   translation for :too_short.
      # * <tt>with_long_message</tt> - value the test expects to find in
      #   <tt>errors.on(:attribute)</tt>. Regexp or string.  Defaults to the
      #   translation for :too_long.
      # * <tt>with_message</tt> - value the test expects to find in
      #   <tt>errors.on(:attribute)</tt>. Regexp or string.  Defaults to the
      #   translation for :wrong_length. Used in conjunction with
      #   <tt>is_equal_to</tt>.
      #
      # Examples:
      #   it { should ensure_length_of(:password).
      #                 is_at_least(6).
      #                 is_at_most(20) }
      #   it { should ensure_length_of(:name).
      #                 is_at_least(3).
      #                 with_short_message(/not long enough/) }
      #   it { should ensure_length_of(:ssn).
      #                 is_equal_to(9).
      #                 with_message(/is invalid/) }
      def ensure_length_of(attr)
        EnsureLengthOfMatcher.new(attr)
      end

      class EnsureLengthOfMatcher < ValidationMatcher # :nodoc:
        include Helpers

        def initialize(attribute)
          super(attribute)
          @options = {}
        end

        def is_at_least(length)
          @options[:minimum] = length
          @short_message ||= :too_short
          self
        end

        def is_at_most(length)
          @options[:maximum] = length
          @long_message ||= :too_long
          self
        end

        def is_equal_to(length)
          @options[:minimum] = length
          @options[:maximum] = length
          @short_message ||= :wrong_length
          @long_message ||= :wrong_length
          self
        end

        def with_short_message(message)
          if message
            @short_message = message
          end
          self
        end

        def with_long_message(message)
          if message
            @long_message = message
          end
          self
        end

        def with_message(message)
          if message
            @short_message = message
            @long_message = message
          end
          self
        end

        def description
          description =  "ensure #{@attribute} has a length "
          if @options.key?(:minimum) && @options.key?(:maximum)
            if @options[:minimum] == @options[:maximum]
              description << "of exactly #{@options[:minimum]}"
            else
              description << "between #{@options[:minimum]} and #{@options[:maximum]}"
            end
          else
            description << "of at least #{@options[:minimum]}" if @options[:minimum]
            description << "of at most #{@options[:maximum]}" if @options[:maximum]
          end
          description
        end

        def matches?(subject)
          super(subject)
          translate_messages!
          lower_bound_matches? && upper_bound_matches?
        end

        private

        def translate_messages!
          if Symbol === @short_message
            @short_message = default_error_message(@short_message,
                                                   :model_name => @subject.class.to_s.underscore,
                                                   :instance => @subject,
                                                   :attribute => @attribute,
                                                   :count => @options[:minimum])
          end

          if Symbol === @long_message
            @long_message = default_error_message(@long_message,
                                                  :model_name => @subject.class.to_s.underscore,
                                                  :instance => @subject,
                                                  :attribute => @attribute,
                                                  :count => @options[:maximum])
          end
        end

        def lower_bound_matches?
          disallows_lower_length? && allows_minimum_length?
        end

        def upper_bound_matches?
          disallows_higher_length? && allows_maximum_length?
        end

        def disallows_lower_length?
          if @options.key?(:minimum)
            @options[:minimum] == 0 ||
              disallows_length_of?(@options[:minimum] - 1, @short_message)
          else
            true
          end
        end

        def disallows_higher_length?
          if @options.key?(:maximum)
            disallows_length_of?(@options[:maximum] + 1, @long_message)
          else
            true
          end
        end

        def allows_minimum_length?
          if @options.key?(:minimum)
            allows_length_of?(@options[:minimum], @short_message)
          else
            true
          end
        end

        def allows_maximum_length?
          if @options.key?(:maximum)
            allows_length_of?(@options[:maximum], @long_message)
          else
            true
          end
        end

        def allows_length_of?(length, message)
          allows_value_of(string_of_length(length), message)
        end

        def disallows_length_of?(length, message)
          disallows_value_of(string_of_length(length), message)
        end

        def string_of_length(length)
          'x' * length
        end
      end
    end
  end
end
