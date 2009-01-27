require 'shoulda/active_record/helpers'
require 'shoulda/active_record/matchers/validation_matcher'
require 'shoulda/active_record/matchers/allow_value_matcher'
require 'shoulda/active_record/matchers/ensure_length_of_matcher'
require 'shoulda/active_record/matchers/ensure_inclusion_of_matcher'
require 'shoulda/active_record/matchers/validate_presence_of_matcher'
require 'shoulda/active_record/matchers/validate_uniqueness_of_matcher'
require 'shoulda/active_record/matchers/validate_acceptance_of_matcher'
require 'shoulda/active_record/matchers/validate_numericality_of_matcher'
require 'shoulda/active_record/matchers/association_matcher'
require 'shoulda/active_record/matchers/have_db_column_matcher'
require 'shoulda/active_record/matchers/have_index_matcher'
require 'shoulda/active_record/matchers/have_readonly_attribute_matcher'
require 'shoulda/active_record/matchers/allow_mass_assignment_of_matcher'
require 'shoulda/active_record/matchers/have_named_scope_matcher'


module Shoulda # :nodoc:
  module ActiveRecord # :nodoc:
    # = Matchers for your active record models
    #
    # These matchers will test most of the validations and associations for your
    # ActiveRecord models.
    #
    #   describe User do
    #     it { should validate_presence_of(:name) }
    #     it { should validate_presence_of(:phone_number) }
    #     %w(abcd 1234).each do |value|
    #       it { should_not allow_value(value).for(:phone_number) }
    #     end
    #     it { should allow_value("(123) 456-7890").for(:phone_number) }
    #     it { should_not allow_mass_assignment_of(:password) }
    #     it { should have_one(:profile) }
    #     it { should have_many(:dogs) }
    #     it { should have_many(:messes).through(:dogs) }
    #     it { should belong_to(:lover) }
    #   end
    #
    module Matchers
    end
  end
end
