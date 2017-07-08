require_relative 'helpers/model_builder'

module UnitTests
  class RecordValidatingConfirmationBuilder
    include ModelBuilder

    def initialize(options)
      @options = options
    end

    def model
      @_model ||= create_model
    end

    def model_name
      'Example'
    end

    def record
      model.new
    end

    def message=(message)
      options[:message] = message
    end

    def attribute_to_confirm
      options.fetch(:attribute, :attribute_to_confirm)
    end

    def confirmation_attribute
      :"#{attribute_to_confirm}_confirmation"
    end

    def attribute_that_receives_error
      confirmation_attribute
    end

    protected

    attr_reader :options

    private

    def create_model
      define_model(model_name, attribute_to_confirm => :string) do |model|
        model.validates_confirmation_of(attribute_to_confirm, options)
      end
    end
  end
end
