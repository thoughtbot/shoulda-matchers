require 'shoulda'
require 'shoulda/action_mailer/assertions'
require 'shoulda/action_mailer/matchers'

module Test # :nodoc: all
  module Unit
    class TestCase
      include Shoulda::ActionMailer::Assertions
      include Shoulda::ActionMailer::Matchers
      extend Shoulda::ActionMailer::Matchers
    end
  end
end
