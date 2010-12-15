# :enddoc:

if defined?(::ActiveRecord)
  require 'shoulda/active_record'
  module RSpec::Matchers
    include Shoulda::ActiveRecord
  end
end

if defined?(::ActionController)
  require 'shoulda/action_controller'
  module RSpec::Rails::ControllerExampleGroup
    include Shoulda::ActionController
  end
end

if defined?(::ActionMailer)
  require 'shoulda/action_mailer'
  module RSpec::Rails::MailerExampleGroup
    include Shoulda::ActionMailer
  end
end

