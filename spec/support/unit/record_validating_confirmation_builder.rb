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

    def attribute
      options.fetch(:attribute, :attribute)
    end

    def confirmation_attribute
      :"#{attribute}_confirmation"
    end

    def attribute_that_receives_error
      confirmation_attribute
    end

    protected

    attr_reader :options

    private

    def create_model
      _attribute = attribute
      _options = options

      define_model(model_name, _attribute => :string) do
        validates_confirmation_of(_attribute, _options)
      end
    end
  end
end
