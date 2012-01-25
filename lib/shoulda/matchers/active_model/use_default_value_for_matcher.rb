module Shoulda # :nodoc:
  module Matchers
    module ActiveModel # :nodoc:

      # Ensures that the attribute's default value is set correctly.
      #
      # Example:
      #   it { should_not use_default_value(0).for(:count) }  #the :count field's default value is not 0
      #   it { should_not use_default_value.for(:count) }     #the :count field has no default value (e.g. it's default value is nil)
      #   it { should use_default_value(0).for(:count) }      #the :count field's default value is O
      #   it { should use_default_value.for(:count) }         #the :count field has a default value (e.g. it's default value is not nil)
      #
      def use_default_value(value=nil)
        UseDefaultValueMatcher.new(value)
      end

      class UseDefaultValueMatcher # :nodoc:

        def initialize(value)
          @default_value = value
        end

        def for(attribute)
          @attribute = attribute
          self
        end

        def matches?(instance)
           #instance.send("#{@attribute}=".to_sym) = nil
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
          "checks if the #{@attribute}'s default value is #{@default_value.inspect}"
        end

        private

        def value
          @instance.send(@attribute.to_sym)
        end
      end

    end
  end
end
