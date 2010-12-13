require 'shoulda'
require 'shoulda/action_mailer/matchers'

module Test # :nodoc: all
  module Unit
    class TestCase
      include Shoulda::ActionMailer::Matchers
      extend Shoulda::ActionMailer::Matchers
    end
  end
end
