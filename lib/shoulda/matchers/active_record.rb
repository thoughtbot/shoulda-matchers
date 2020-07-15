require "shoulda/matchers/active_record/validate_uniqueness_of_matcher"

module Shoulda
  module Matchers
    # This module provides matchers that are used to test behavior within
    # ActiveRecord classes.
    module ActiveRecord
      autoload :AcceptNestedAttributesForMatcher, 'shoulda/matchers/active_record/accept_nested_attributes_for_matcher'
      autoload :AssociationMatcher, 'shoulda/matchers/active_record/association_matcher'
      autoload :AssociationMatchers, 'shoulda/matchers/active_record/association_matchers'
      autoload :DefineEnumForMatcher, 'shoulda/matchers/active_record/define_enum_for_matcher'
      autoload :HaveAttachedMatcher, 'shoulda/matchers/active_record/have_attached_matcher'
      autoload :HaveDbColumnMatcher, 'shoulda/matchers/active_record/have_db_column_matcher'
      autoload :HaveDbIndexMatcher, 'shoulda/matchers/active_record/have_db_index_matcher'
      autoload :HaveImplicitOrderColumnMatcher, 'shoulda/matchers/active_record/have_implicit_order_column'
      autoload :HaveReadonlyAttributeMatcher, 'shoulda/matchers/active_record/have_readonly_attribute_matcher'
      autoload :HaveRichText, 'shoulda/matchers/active_record/have_rich_text_matcher'
      autoload :HaveSecureTokenMatcher, 'shoulda/matchers/active_record/have_secure_token_matcher'
      autoload :SerializeMatcher, 'shoulda/matchers/active_record/serialize_matcher'
      autoload :Uniqueness, 'shoulda/matchers/active_record/uniqueness'
    end
  end
end
