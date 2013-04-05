require 'shoulda/matchers/active_record/association_matcher'
require 'shoulda/matchers/active_record/have_db_column_matcher'
require 'shoulda/matchers/active_record/have_db_index_matcher'
require 'shoulda/matchers/active_record/have_readonly_attribute_matcher'
require 'shoulda/matchers/active_record/serialize_matcher'
require 'shoulda/matchers/active_record/accept_nested_attributes_for_matcher'

module Shoulda
  module Matchers
    # = Matchers for your active record models
    #
    # These matchers will test the associations for your
    # ActiveRecord models.
    #
    #   describe User do
    #     it { should have_one(:profile) }
    #     it { should have_many(:dogs) }
    #     it { should have_many(:messes).through(:dogs) }
    #     it { should belong_to(:lover) }
    #   end
    #
    module ActiveRecord
    end
  end
end
