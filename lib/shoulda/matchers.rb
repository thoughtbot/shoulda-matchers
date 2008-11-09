require 'shoulda/active_record/matchers'

module Thoughtbot
  module Shoulda
    module Matchers # :nodoc:
      include ThoughtBot::Shoulda::ActiveRecord::Matchers
    end
  end
end
