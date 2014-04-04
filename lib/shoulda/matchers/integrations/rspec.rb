# :enddoc:

if RSpec.respond_to?(:configure)
  RSpec.configure do |config|
    config.include Shoulda::Matchers::Independent

    if defined?(ActiveRecord)
      config.include Shoulda::Matchers::ActiveRecord
    end

    if defined?(ActiveModel)
      config.include Shoulda::Matchers::ActiveModel
    end

    if defined?(ActionController)
      config.include Shoulda::Matchers::ActionController
    end
  end
end
