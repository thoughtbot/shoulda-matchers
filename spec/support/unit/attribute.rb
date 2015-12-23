module UnitTests
  class Attribute
    attr_reader :name, :column_type, :column_options

    DEFAULT_COLUMN_TYPE = :string
    DEFAULT_COLUMN_OPTIONS = {
      null: false,
      array: false
    }

    def initialize(args)
      @args = args
    end

    def name
      args.fetch(:name)
    end

    def column_type
      args.fetch(:column_type, DEFAULT_COLUMN_TYPE)
    end

    def column_options
      DEFAULT_COLUMN_OPTIONS.
        merge(args.fetch(:column_options, {})).
        merge(type: column_type)
    end

    def array?
      column_options[:array]
    end

    def default_value
      args.fetch(:default_value) do
        if column_options[:null]
          nil
        else
          Shoulda::Matchers::Util.dummy_value_for(value_type, array: array?)
        end
      end
    end

    protected

    attr_reader :args
  end
end
