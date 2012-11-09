module Shoulda # :nodoc:
  module Matchers
    module ActiveModel # :nodoc:

      # Ensures that the model is not valid if the given attribute is not
      # formatted correctly.
      #
      # Options:
      # * <tt>with_message</tt> - value the test expects to find in
      #   <tt>allow_blank</tt> - allows a blank value
      #   <tt>allow_nil</tt> - allows a nil value
      #   <tt>errors.on(:attribute)</tt>. <tt>Regexp</tt> or <tt>String</tt>.
      #   Defaults to the translation for <tt>:invalid</tt>.
      # * <tt>with(string to test against)</tt>
      # * <tt>not_with(string to test against)</tt>
      #
      # Examples:
      #   it { should validate_format_of(:name).
      #                 with('12345').
      #                 with_message(/is not optional/) }
      #   it { should validate_format_of(:name).
      #                 not_with('12D45').
      #                 with_message(/is not optional/) }
      #
      def validate_format_of(attr)
        ValidateFormatOfMatcher.new(attr)
      end

      class ValidateFormatOfMatcher < ValidationMatcher # :nodoc:

        CHARSET = (0..591).map{ |c| c.chr("UTF-8") }

        def initialize(attribute)
          super
          @options = {}
        end

        def allowing(value)
          raise "You may not call both #allowing and #denying" if @value_should
          @value_should = :pass
          @value = value
          self
        end

        def denying(value)
          raise "You may not call both #allowing and #denying" if @value_should
          @value_should = :fail
          @value = value
          self
        end

        def allow_blank(allow_blank = true)
          @options[:allow_blank] = allow_blank
          self
        end

        def allow_nil(allow_nil = true)
          @options[:allow_nil] = allow_nil
          self
        end

        def placing(*values)
          @characters = values.map{ |v| v.kind_of?(Regexp) ? CHARSET.grep(v) : v }.flatten.uniq
          self
        end

        def at(*position)
          @at = position.map{ |pos| pos.kind_of?(Range) ? pos.to_a : pos }.flatten.uniq
          self
        end

        def with_message(message)
          @expected_message = message if message
          self
        end

        def matches?(subject)
          super(subject)

          raise "Matcher needs a example value, use #allowing or #denying methods to fix it." unless @value_should || @options.any?

          case @value_should
          when :fail
            match_calling?(:disallows_value_of)
          when :pass
            match_calling?(:allows_value_of)
          else
            allows_blank_value? && allows_nil_value?
          end
        end

        def description
          "#{@attribute} have a valid format"
        end

        private

        def words
          return [@value] unless @characters

          list = []
          word = @value.dup
          @characters.each do |character|
            @at ||= [rand(@value.size)]
            @at.each { |i| word[i] = character }
            list << word
          end
          list
        end

        def allows_blank_value?
          if @options.key?(:allow_blank)
            @options[:allow_blank] == allows_value_of('')
          else
            true
          end
        end

        def allows_nil_value?
          if @options.key?(:allow_nil)
            @options[:allow_nil] == allows_value_of(nil)
          else
            true
          end
        end

        def match_calling?(method)
          @expected_message ||= :invalid
          words.each { |w| return unless send(method, w, @expected_message) }
          true
        end
      end
    end
  end
end