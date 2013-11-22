begin
  require 'rspec/core'
rescue LoadError
  # Don't worry, be happy now.
else
  RSpec.configure do |config|
    if defined?(::ActiveRecord)
      require 'shoulda/matchers/active_record'
      require 'shoulda/matchers/active_model'
      config.include Shoulda::Matchers::ActiveRecord
      config.include Shoulda::Matchers::ActiveModel

    elsif defined?(::ActiveModel)
      require 'shoulda/matchers/active_model'
      config.include Shoulda::Matchers::ActiveModel
    end

    if defined?(::ActionController)
      require 'shoulda/matchers/action_controller'
      config.include Shoulda::Matchers::ActionController
    end
  end
end
