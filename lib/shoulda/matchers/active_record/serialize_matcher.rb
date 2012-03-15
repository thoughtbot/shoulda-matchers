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
      #
      def serialize(name)
        SerializeMatcher.new(name)
      end

      class SerializeMatcher # :nodoc:
        def initialize(name)
          @name = name.to_s
        end

        def as(type)
          @type = type
          self
        end
        
        def as_instance_of(type)
          @instance_type = type
          self
        end

        def matches?(subject)
          @subject = subject
          serialization_valid? && type_valid?
        end

        def failure_message
          "Expected #{expectation} (#{@missing})"
        end

        def negative_failure_message
          "Did not expect #{expectation}"
        end

        def description
          description = "serialize :#{@name}"
          description += " class_name => #{@type}" if @type
          description
        end

        protected

        def model_class
          @subject.class
        end

        def serialization_valid?
          if model_class.serialized_attributes.keys.include?(@name)
            true
          else
            @missing = "no serialized attribute called :#{@name}"
            false
          end
        end
        
        def class_valid?
          if @type
            model_class.serialized_attributes[@name] == @type
          else
            true
          end
        end
        
        def instance_class_valid?
          if @instance_type
            klass = model_class.serialized_attributes[@name].class
            klass == @instance_type
          else
            true
          end
        end

        def type_valid?
          class_valid? && instance_class_valid?
        end

        def expectation
          expectation = "#{model_class.name} to serialize the attribute called :#{@name}"
          expectation += " with a type of #{@type}" if @type
          expectation
        end
      end
    end
  end
end