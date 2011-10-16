require 'shoulda/matchers/active_model/helpers'
require 'shoulda/matchers/active_model/validation_matcher'
require 'shoulda/matchers/active_model/allow_value_matcher'
require 'shoulda/matchers/active_model/ensure_length_of_matcher'
require 'shoulda/matchers/active_model/ensure_inclusion_of_matcher'
require 'shoulda/matchers/active_model/ensure_exclusion_of_matcher'
require 'shoulda/matchers/active_model/validate_presence_of_matcher'
require 'shoulda/matchers/active_model/validate_format_of_matcher'
require 'shoulda/matchers/active_model/validate_uniqueness_of_matcher'
require 'shoulda/matchers/active_model/validate_acceptance_of_matcher'
require 'shoulda/matchers/active_model/validate_numericality_of_matcher'
require 'shoulda/matchers/active_model/allow_mass_assignment_of_matcher'


module Shoulda
  module Matchers
    # = Matchers for your active record models
    #
    # These matchers will test most of the validations of ActiveModel::Validations.
    #
    #   describe User do
    #     it { should validate_presence_of(:name) }
    #     it { should validate_presence_of(:phone_number) }
    #     %w(abcd 1234).each do |value|
    #       it { should_not allow_value(value).for(:phone_number) }
    #     end
    #     it { should allow_value("(123) 456-7890").for(:phone_number) }
    #     it { should_not allow_mass_assignment_of(:password) }
    #   end
    #
    module ActiveModel
    end
  end
end
