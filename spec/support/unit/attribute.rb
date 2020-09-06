module UnitTests
  class Attribute
    DEFAULT_COLUMN_TYPE = :string
    DEFAULT_COLUMN_OPTIONS = {
      null: false,
      array: false,
    }.freeze

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
      {
        type: column_type,
        options: DEFAULT_COLUMN_OPTIONS.merge(args.fetch(:column_options, {})),
      }
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
