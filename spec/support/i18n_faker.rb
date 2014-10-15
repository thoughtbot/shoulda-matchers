module I18nFaker
  extend self

  def stub_translation(key_or_keys, message)
    keys = [key_or_keys].flatten.join('.').split('.')
    tree = keys.reverse.inject(message) { |data, key| { key => data } }
    I18n.backend.store_translations(:en, tree)
  end
end

RSpec.configure do |config|
  config.include I18nFaker
end
