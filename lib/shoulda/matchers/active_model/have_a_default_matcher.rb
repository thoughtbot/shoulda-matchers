module Shoulda # :nodoc:
  module Matchers
    module ActiveModel # :nodoc:

      # Ensures that the attribute's default value is set correctly.
      #
      # Example:
      #   # the :count field's default value is 0
      #   it { should have_a_default.of(0).for(:count) }
      #   it { should have_a_default.of(0).for(:count).column }
      #   it { should have_a_default.of(0).for(:count).attribute }
      #
      #   # the :count field has a default value (e.g. it's default value is not nil)
      #   it { should have_a_default.for(:count) }
      #   it { should have_a_default.for(:count).column }
      #   it { should have_a_default.for(:count).attribute }
      #
      #   # the :count field's default value is not 0
      #   it { should_not have_a_default.of(0).for(:count) }
      #   it { should_not have_a_default.of(0).for(:count).column }
      #   it { should_not have_a_default.of(0).for(:count).attribute }
      #
      #   # the :count field does not have a default value (e.g. it's default value is nil)
      #   it { should_not have_a_default.for(:count) }
      #   it { should_not have_a_default.for(:count).column }
      #   it { should_not have_a_default.for(:count).attribute }
      #
      def have_a_default
        HaveADefaultMatcher.new
      end

      # Same as have_a_default.of
      #
      # Example:
      #   # the :count field's default value is 0
      #   it { should default_to(0).on_the(:count).column }
      #   it { should default_to(0).on_the(:count).attribute }
      #
      #   # the :count field's default value is not 0
      #   it { should_not default_to(0).on_the(:count).column }
      #   it { should_not default_to(0).on_the(:count).attribute }
      #
      def default_to(value)
        have_a_default.of(value)
      end

      class HaveADefaultMatcher # :nodoc:

        def of(value)
           @default_value = value
           self
        end

        def for(attribute)
          @attribute = attribute
          self
        end
        alias :on_the :for

        def column
           self    #syntactic sugar
        end
        alias :attribute :column

        def matches?(instance)
           @instance = instance
           @instance.valid?
           @default_value.nil? ? value : value == @default_value
        end

        def failure_message
          if @default_value
            "Expected default value for #{@attribute} to be #{@default_value.inspect} but it was #{value.inspect} !"
          else
            "Expected to find a default value for #{@attribute} but there wasn't any !"
          end
        end

        def negative_failure_message
          if @default_value
            "Expected default value for #{@attribute} not to be #{@default_value.inspect} but it was!"
          else
            "Not expecting to find a default value for #{@attribute} but found #{value.inspect}!"
          end
        end

        def description
          "check if the #{@attribute}'s default value is #{@default_value.inspect}"
        end

        private

        def value
          @instance.send(@attribute.to_sym)
        end
      end

    end
  end
end
