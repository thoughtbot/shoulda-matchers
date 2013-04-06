module I18nFaker
 
  # Stub a translation value in the en.yml file.  Note, you need to call I18n.backend.reload! restore the original value after each spec.
  def stub_translation(key, message)
    yml =  key.split('.').reverse.inject(message) { |a, n| { n => a } }
    I18n.backend.store_translations(:en, yml)
  end
end
 
RSpec.configure do |config|
  config.include I18nFaker
end