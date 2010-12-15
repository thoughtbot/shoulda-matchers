# :enddoc:

if defined?(::ActiveRecord)
  require 'shoulda/matchers/active_record'
  module RSpec::Matchers
    include Shoulda::Matchers::ActiveRecord
  end
end

if defined?(::ActionController)
  require 'shoulda/matchers/action_controller'
  module RSpec::Rails::ControllerExampleGroup
    include Shoulda::Matchers::ActionController
  end
end

if defined?(::ActionMailer)
  require 'shoulda/matchers/action_mailer'
  module RSpec::Rails::MailerExampleGroup
    include Shoulda::Matchers::ActionMailer
  end
end

