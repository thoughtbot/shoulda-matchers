# :enddoc:
require 'rspec/core'

RSpec.configure do |config|
  if defined?(::ActiveRecord)
    require 'shoulda/matchers/active_record'
    require 'shoulda/matchers/active_model'

    config.include Shoulda::Matchers::ActiveRecord , :type => :model, 
      :example_group => { :file_path => /spec\/models/ }

    config.include Shoulda::Matchers::ActiveModel, :type => :model,
      :example_group => { :file_path => /spec\/models/ }

  elsif defined?(::ActiveModel)
    require 'shoulda/matchers/active_model'
    config.include Shoulda::Matchers::ActiveModel, :type => :model,
      :example_group => { :file_path => /spec\/models/ }
  end

  if defined?(::ActionController)
    require 'shoulda/matchers/action_controller'
    config.include Shoulda::Matchers::ActionController, :type => :controller,
      :example_group => { :file_path => /spec\/controllers/ }
  end
end
