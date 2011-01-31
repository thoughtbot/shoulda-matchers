# :enddoc:

if defined?(::ActiveRecord)
  require 'shoulda/matchers/active_record'
  module RSpec::Matchers
    include Shoulda::Matchers::ActiveRecord
  end
end

if defined?(::ActionController)
  require 'shoulda/matchers/action_controller'
  module RSpec
    module Rails
      module ControllerExampleGroup
        include Shoulda::Matchers::ActionController
      end
    end
  end
end

if defined?(::ActionMailer)
  require 'shoulda/matchers/action_mailer'
  module RSpec
    module Rails
      module MailerExampleGroup
        include Shoulda::Matchers::ActionMailer
      end
    end
  end
end

