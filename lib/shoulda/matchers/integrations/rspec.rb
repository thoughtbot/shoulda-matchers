# :enddoc:
require 'rspec/core'

RSpec.configure do |config|
  require 'shoulda/matchers/independent'
  config.include Shoulda::Matchers::Independent

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
    if defined?(::Turbolinks)
      require 'shoulda/matchers/turbolinks'
      config.include Shoulda::Matchers::Turbolinks
    end
  end
end
