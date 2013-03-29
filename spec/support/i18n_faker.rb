module I18nFaker
  def stub_translation(key, message)
    yml =  key.split('.').reverse.inject(message) { |a, n| { n => a } }
    I18n.backend.store_translations(:en, yml)
  end
end

RSpec.configure do |config|
  config.include I18nFaker
end
