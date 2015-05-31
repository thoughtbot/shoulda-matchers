module UnitTests
  module I18nFaker
    extend self

    def self.configure_example_group(example_group)
      example_group.include(self)
    end

    def stub_translation(key_or_keys, message)
      keys = [key_or_keys].flatten.join('.').split('.')
      tree = keys.reverse.inject(message) { |data, key| { key => data } }
      I18n.backend.store_translations(:en, tree)
    end

    def stub_validation_error(args)
      model_name = args.delete(:model_name)
      attribute_name = args.delete(:attribute_name)
      message = args.delete(:message)
      value = args.delete(:value)
      keys =
        %w(activerecord errors models) +
        [model_name] +
        %w(attributes) +
        [attribute_name, message]

      stub_translation(keys, value)
    end
  end
end
