# :enddoc:

if defined?(::ActiveRecord)
  require 'shoulda/matchers/active_record'
  require 'shoulda/matchers/active_model'
  module RSpec::Matchers
    include Shoulda::Matchers::ActiveRecord
    include Shoulda::Matchers::ActiveModel
  end
elsif defined?(::ActiveModel)
  require 'shoulda/matchers/active_model'
  module RSpec::Matchers
    include Shoulda::Matchers::ActiveModel
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
