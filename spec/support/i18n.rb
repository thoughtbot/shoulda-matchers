RSpec.configure do |config|
  config.after do
    # Clear any translations added during tests by telling the backend to
    # replace its translations with whatever is in the YAML files.
    I18n.backend.reload!
  end
end
