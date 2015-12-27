require 'forwardable'

module UnitTests
  class ValidationMatcherScenario
    extend Forwardable

    attr_reader :matcher

    def initialize(arguments)
      @arguments = arguments.dup
      @matcher_proc = @arguments.delete(:matcher_proc)

      @specified_model_creator = @arguments.delete(:model_creator) do
        raise KeyError.new(<<-MESSAGE)
:model_creator is missing. You can either provide it as an option or as
a method.
        MESSAGE
      end

      @model_creator = model_creator_class.new(@arguments)
    end

    def record
      @_record ||= model.new.tap do |record|
        attribute_default_values_by_name.each do |attribute_name, default_value|
          record.public_send("#{attribute_name}=", default_value)
        end
      end
    end

    def model
      @_model ||= model_creator.call
    end

    def matcher
      @_matcher ||= matcher_proc.call(attribute_name)
    end

    protected

    attr_reader(
      :arguments,
      :existing_value,
      :matcher_proc,
      :model_creator,
      :specified_model_creator,
    )

    private

    def_delegators(
      :model_creator,
      :attribute_name,
      :attribute_default_values_by_name,
    )

    def model_creator_class
      UnitTests::ModelCreators.retrieve(specified_model_creator) ||
        specified_model_creator
    end
  end
end
