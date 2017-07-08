require 'forwardable'

module UnitTests
  module CreateModelArguments
    class Basic
      DEFAULT_MODEL_NAME = 'Example'
      DEFAULT_ATTRIBUTE_NAME = :attr
      DEFAULT_COLUMN_TYPE = :string

      def self.wrap(args)
        if args.is_a?(self)
          args
        else
          new(args)
        end
      end

      extend Forwardable

      def_delegators(
        :attribute,
        :column_type,
        :column_options,
        :default_value,
        :value_type
      )

      def initialize(args)
        @args = args
      end

      def fetch(*args, &block)
        self.args.fetch(*args, &block)
      end

      def merge(given_args)
        self.class.new(args.deep_merge(given_args))
      end

      def model_name
        args.fetch(:model_name, DEFAULT_MODEL_NAME)
      end

      def attribute_name
        args.fetch(:attribute_name, default_attribute_name)
      end

      def model_creation_strategy
        args.fetch(:model_creation_strategy)
      end

      def columns
        { attribute_name => column_options }
      end

      def attribute
        @_attribute ||= attribute_class.new(attribute_args)
      end

      def all_attribute_overrides
        @_all_attribute_overrides ||= begin
          attribute_overrides = args.slice(
            :changing_values_with,
            :default_value
          )

          overrides =
            if attribute_overrides.empty?
              {}
            else
              { attribute_name => attribute_overrides }
            end

          overrides.deep_merge(args.fetch(:attribute_overrides, {}))
        end
      end

      def attribute_overrides
        all_attribute_overrides.fetch(attribute_name, {})
      end

      def validation_name
        args.fetch(:validation_name) { map_matcher_name_to_validation_name }
      end

      def validation_options
        args.fetch(:validation_options, {})
      end

      def custom_validation?
        args.fetch(:custom_validation, false)
      end

      def matcher_name
        args.fetch(:matcher_name)
      end

      def attribute_default_values_by_name
        if attribute_overrides.key?(:default_value)
          { attribute_name => attribute_overrides[:default_value] }
        else
          {}
        end
      end

      def to_hash
        args.deep_dup
      end

      protected

      attr_reader :args

      def attribute_class
        UnitTests::Attribute
      end

      def default_attribute_name
        DEFAULT_ATTRIBUTE_NAME
      end

      private

      def map_matcher_name_to_validation_name
        matcher_name.to_s.sub('validate', 'validates')
      end

      def attribute_args
        args.slice(:column_type).deep_merge(
          attribute_overrides.deep_merge(name: attribute_name)
        )
      end
    end
  end
end
