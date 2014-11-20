require_relative 'helpers/model_builder'

module UnitTests
  class RecordWithDifferentErrorAttributeBuilder
    include ModelBuilder

    def initialize(options)
      @options = options.reverse_merge(default_options)
    end

    def attribute_that_receives_error
      options[:attribute_that_receives_error]
    end

    def attribute_to_validate
      options[:attribute_to_validate]
    end

    def message
      options[:message]
    end

    def message=(message)
      options[:message] = message
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

    def valid_value
      'some value'
    end

    protected

    attr_reader :options

    private

    def context
      {
        validation_method_name: validation_method_name,
        valid_value: valid_value,
        attribute_to_validate: attribute_to_validate,
        attribute_that_receives_error: attribute_that_receives_error,
        message: message
      }
    end

    def create_model
      _context = context

      define_model model_name, model_columns do
        validate _context[:validation_method_name]

        define_method(_context[:validation_method_name]) do
          if self[_context[:attribute_to_validate]] != _context[:valid_value]
            self.errors.add(_context[:attribute_that_receives_error], _context[:message])
          end
        end
      end
    end

    def validation_method_name
      :custom_validation
    end

    def model_columns
      {
        attribute_to_validate => :string,
        attribute_that_receives_error => :string
      }
    end

    def default_options
      {
        attribute_that_receives_error: :attribute_that_receives_error,
        attribute_to_validate: :attribute_to_validate,
        message: 'some message'
      }
    end
  end
end
