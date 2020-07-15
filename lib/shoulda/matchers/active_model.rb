require 'shoulda/matchers/active_model/allow_mass_assignment_of_matcher'
require 'shoulda/matchers/active_model/helpers'
require 'shoulda/matchers/active_model/qualifiers'
require 'shoulda/matchers/active_model/validation_matcher'
require 'shoulda/matchers/active_model/validate_absence_of_matcher'
require 'shoulda/matchers/active_model/validate_presence_of_matcher'

module Shoulda
  module Matchers
    # This module provides matchers that are used to test behavior within
    # ActiveModel or ActiveRecord classes.
    #
    # ### Testing conditional validations
    #
    # If your model defines a validation conditionally -- meaning that the
    # validation is declared with an `:if` or `:unless` option -- how do you
    # test it? You might expect the validation matchers here to have
    # corresponding `if` or `unless` qualifiers, but this isn't what you use.
    # Instead, before using the matcher in question, you place the record
    # you're testing in a state such that the validation you're also testing
    # will be run. A common way to do this is to make a new `context` and
    # override the subject to populate the record accordingly. You'll also want
    # to make sure to test that the validation is *not* run when the
    # conditional fails.
    #
    # Here's an example to illustrate what we mean:
    #
    #     class User
    #       include ActiveModel::Model
    #
    #       attr_accessor :role, :admin
    #
    #       validates_presence_of :role, if: :admin
    #     end
    #
    #     # RSpec
    #     RSpec.describe User, type: :model do
    #       context "when an admin" do
    #         subject { User.new(admin: true) }
    #
    #         it { should validate_presence_of(:role) }
    #       end
    #
    #       context "when not an admin" do
    #         subject { User.new(admin: false) }
    #
    #         it { should_not validate_presence_of(:role) }
    #       end
    #     end
    #
    #     # Minitest (Shoulda)
    #     class UserTest < ActiveSupport::TestCase
    #       context "when an admin" do
    #         subject { User.new(admin: true) }
    #
    #         should validate_presence_of(:role)
    #       end
    #
    #       context "when not an admin" do
    #         subject { User.new(admin: false) }
    #
    #         should_not validate_presence_of(:role)
    #       end
    #     end
    #
    module ActiveModel
      autoload :AllowValueMatcher, 'shoulda/matchers/active_model/allow_value_matcher'
      autoload :CouldNotDetermineValueOutsideOfArray, 'shoulda/matchers/active_model/errors'
      autoload :CouldNotSetPasswordError, 'shoulda/matchers/active_model/errors'
      autoload :DisallowValueMatcher, 'shoulda/matchers/active_model/disallow_value_matcher'
      autoload :HaveSecurePasswordMatcher, 'shoulda/matchers/active_model/have_secure_password_matcher'
      autoload :NonNullableBooleanError, 'shoulda/matchers/active_model/errors'
      autoload :NumericalityMatchers, 'shoulda/matchers/active_model/numericality_matchers'
      autoload :ValidateAcceptanceOfMatcher, 'shoulda/matchers/active_model/validate_acceptance_of_matcher'
      autoload :ValidateConfirmationOfMatcher, 'shoulda/matchers/active_model/validate_confirmation_of_matcher'
      autoload :ValidateExclusionOfMatcher, 'shoulda/matchers/active_model/validate_exclusion_of_matcher'
      autoload :ValidateInclusionOfMatcher, 'shoulda/matchers/active_model/validate_inclusion_of_matcher'
      autoload :ValidateLengthOfMatcher, 'shoulda/matchers/active_model/validate_length_of_matcher'
      autoload :ValidateNumericalityOfMatcher, 'shoulda/matchers/active_model/validate_numericality_of_matcher'
      autoload :Validator, 'shoulda/matchers/active_model/validator'
    end
  end
end
