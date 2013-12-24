module Shoulda # :nodoc:
  module Matchers
    module ActiveRecord # :nodoc:
      # Ensure that the field becomes serialized.
      #
      # Options:
      # * <tt>:as</tt> - tests that the serialized attribute makes use of the class_name option.
      #
      # Example:
      #   it { should serialize(:details) }
      #   it { should serialize(:details).as(Hash) }
      #   it { should serialize(:details).as_instance_of(ExampleSerializer) }
      #
      def serialize(name)
        SerializeMatcher.new(name)
      end

      class SerializeMatcher # :nodoc:
        def initialize(name)
          @name = name.to_s
          @options = {}
        end

        def as(type)
          @options[:type] = type
          self
        end

        def as_instance_of(type)
          @options[:instance_type] = type
          self
        end

        def matches?(subject)
          @subject = subject
          serialization_valid? && type_valid?
        end

        def failure_message
          "Expected #{expectation} (#{@missing})"
        end
        alias failure_message_for_should failure_message

        def failure_message_when_negated
          "Did not expect #{expectation}"
        end
        alias failure_message_for_should_not failure_message_when_negated

        def description
          description = "serialize :#{@name}"
          description += " class_name => #{@options[:type]}" if @options.key?(:type)
          description
        end

        protected

        def serialization_valid?
          if model_class.serialized_attributes.keys.include?(@name)
            true
          else
            @missing = "no serialized attribute called :#{@name}"
            false
          end
        end

        def class_valid?
          if @options[:type]
            klass = model_class.serialized_attributes[@name]
            if klass == @options[:type]
              true
            else
              if klass.respond_to?(:object_class) && klass.object_class == @options[:type]
                true
              else
                @missing = ":#{@name} should be a type of #{@options[:type]}"
                false
              end
            end
          else
            true
          end
        end

        def model_class
          @subject.class
        end

        def instance_class_valid?
          if @options.key?(:instance_type)
            if model_class.serialized_attributes[@name].class == @options[:instance_type]
              true
            else
              @missing = ":#{@name} should be an instance of #{@options[:type]}"
              false
            end
          else
            true
          end
        end

        def type_valid?
          class_valid? && instance_class_valid?
        end

        def expectation
          expectation = "#{model_class.name} to serialize the attribute called :#{@name}"
          expectation += " with a type of #{@options[:type]}" if @options[:type]
          expectation += " with an instance of #{@options[:instance_type]}" if @options[:instance_type]
          expectation
        end
      end
    end
  end
end
