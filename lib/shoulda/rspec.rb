require 'shoulda/active_record/matchers'

module Spec # :nodoc:
  module Rails # :nodoc:
    module Matchers # :nodoc:
      include Shoulda::ActiveRecord::Matchers
    end
  end
end
