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
      :attribute_to_confirm
    end
    alias_method :attribute, :attribute_to_confirm

    def confirmation_attribute
      :"#{attribute_to_confirm}_confirmation"
    end

    def attribute_that_receives_error
      Shoulda::Matchers::RailsShim.
        validates_confirmation_of_error_attribute(self)
    end

    protected

    attr_reader :options

    private

    def create_model
      _attribute = attribute_to_confirm
      _options = options

      define_model(model_name, _attribute => :string) do
        validates_confirmation_of(_attribute, _options)
      end
    end
  end
end
