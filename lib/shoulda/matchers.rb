require 'shoulda/matchers/configuration'
require 'shoulda/matchers/version'
require 'shoulda/matchers/warn'

module Shoulda
  module Matchers
    autoload :ActionController, 'shoulda/matchers/action_controller'
    autoload :ActiveModel, 'shoulda/matchers/active_model'
    autoload :ActiveRecord, 'shoulda/matchers/active_record'
    autoload :Doublespeak, 'shoulda/matchers/doublespeak'
    autoload :Error, 'shoulda/matchers/error'
    autoload :Independent, 'shoulda/matchers/independent'
    autoload :Integrations, 'shoulda/matchers/integrations'
    autoload :MatcherContext, 'shoulda/matchers/matcher_context'
    autoload :RailsShim, 'shoulda/matchers/rails_shim'
    autoload :Routing, 'shoulda/matchers/routing'
    autoload :Util, 'shoulda/matchers/util'
    autoload :WordWrap, 'shoulda/matchers/util/word_wrap'

    class << self
      # @private
      attr_accessor :assertion_exception_class
    end
  end
end
