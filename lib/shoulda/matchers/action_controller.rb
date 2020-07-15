require 'shoulda/matchers/action_controller/respond_with_matcher'
require 'shoulda/matchers/action_controller/route_matcher'

module Shoulda
  module Matchers
    # This module provides matchers that are used to test behavior within
    # controllers.
    module ActionController
      autoload :CallbackMatcher, 'shoulda/matchers/action_controller/callback_matcher'
      autoload :FlashStore, 'shoulda/matchers/action_controller/flash_store'
      autoload :FilterParamMatcher, 'shoulda/matchers/action_controller/filter_param_matcher'
      autoload :PermitMatcher, 'shoulda/matchers/action_controller/permit_matcher'
      autoload :RedirectToMatcher, 'shoulda/matchers/action_controller/redirect_to_matcher'
      autoload :RenderTemplateMatcher, 'shoulda/matchers/action_controller/render_template_matcher'
      autoload :RenderWithLayoutMatcher, 'shoulda/matchers/action_controller/render_with_layout_matcher'
      autoload :RescueFromMatcher, 'shoulda/matchers/action_controller/rescue_from_matcher'
      autoload :RouteParams, 'shoulda/matchers/action_controller/route_params'
      autoload :SessionStore, 'shoulda/matchers/action_controller/session_store'
      autoload :SetFlashMatcher, 'shoulda/matchers/action_controller/set_flash_matcher'
      autoload :SetSessionMatcher, 'shoulda/matchers/action_controller/set_session_matcher'
      autoload :SetSessionOrFlashMatcher, 'shoulda/matchers/action_controller/set_session_or_flash_matcher'
    end
  end
end
