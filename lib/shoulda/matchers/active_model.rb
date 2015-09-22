require 'shoulda/matchers/active_model/helpers'
require 'shoulda/matchers/active_model/validation_matcher'
require 'shoulda/matchers/active_model/validator'
require 'shoulda/matchers/active_model/strict_validator'
require 'shoulda/matchers/active_model/validator_with_captured_range_error'
require 'shoulda/matchers/active_model/allow_value_matcher'
require 'shoulda/matchers/active_model/disallow_value_matcher'
require 'shoulda/matchers/active_model/validate_length_of_matcher'
require 'shoulda/matchers/active_model/validate_inclusion_of_matcher'
require 'shoulda/matchers/active_model/validate_exclusion_of_matcher'
require 'shoulda/matchers/active_model/validate_absence_of_matcher'
require 'shoulda/matchers/active_model/validate_presence_of_matcher'
require 'shoulda/matchers/active_model/validate_acceptance_of_matcher'
require 'shoulda/matchers/active_model/validate_confirmation_of_matcher'
require 'shoulda/matchers/active_model/validate_numericality_of_matcher'
require 'shoulda/matchers/active_model/numericality_matchers/numeric_type_matcher'
require 'shoulda/matchers/active_model/numericality_matchers/comparison_matcher'
require 'shoulda/matchers/active_model/numericality_matchers/odd_number_matcher'
require 'shoulda/matchers/active_model/numericality_matchers/even_number_matcher'
require 'shoulda/matchers/active_model/numericality_matchers/only_integer_matcher'
require 'shoulda/matchers/active_model/allow_mass_assignment_of_matcher'
require 'shoulda/matchers/active_model/errors'
require 'shoulda/matchers/active_model/have_secure_password_matcher'

module Shoulda
  module Matchers
    # #### Conditional validation
    #
    # None of the validations matchers provide a conditional qualifier, but you
    # can define a explicit subject to be tested and this way test a conditional
    # validation.
    #
    #     class User
    #       include ActiveModel::Model
    #       attr_accessor :role, :admin
    #
    #       validates_presence_of :role, if: admin?
    #     end
    #
    #     # RSpec
    #     describe User do
    #       context "admin?" do
    #         it "validates presence of role when true" do
    #           User.new(admin: true).should validate_presence_of(:role)
    #         end
    #
    #         it "does not validates presence of role when false" do
    #           User.new(admin: false).should_not validate_presence_of(:role)
    #         end
    #       end
    #     end
    #
    #     # Test::Unit
    #     class UsetTest < ActiveSupport::TestCase
    #       context "admin?" do
    #         context "validates presence of role when true" do
    #           subject { User.new(admin: true) }
    #           should validate_presence_of(:role)
    #         end
    #
    #         context "does not validates presence of role when false" do
    #           subject { User.new(admin: false) }
    #           should_not validate_presence_of(:role)
    #         end
    #       end
    #     end
    module ActiveModel
    end
  end
end
