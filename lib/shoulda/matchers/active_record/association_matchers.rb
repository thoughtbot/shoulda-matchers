module Shoulda
  module Matchers
    module ActiveRecord
      # @private
      module AssociationMatchers
        autoload :CounterCacheMatcher, 'shoulda/matchers/active_record/association_matchers/counter_cache_matcher'
        autoload :InverseOfMatcher, 'shoulda/matchers/active_record/association_matchers/inverse_of_matcher'
        autoload :JoinTableMatcher, 'shoulda/matchers/active_record/association_matchers/join_table_matcher'
        autoload :OrderMatcher, 'shoulda/matchers/active_record/association_matchers/order_matcher'
        autoload :ThroughMatcher, 'shoulda/matchers/active_record/association_matchers/through_matcher'
        autoload :DependentMatcher, 'shoulda/matchers/active_record/association_matchers/dependent_matcher'
        autoload :RequiredMatcher, 'shoulda/matchers/active_record/association_matchers/required_matcher'
        autoload :OptionalMatcher, 'shoulda/matchers/active_record/association_matchers/optional_matcher'
        autoload :SourceMatcher, 'shoulda/matchers/active_record/association_matchers/source_matcher'
        autoload :ModelReflector, 'shoulda/matchers/active_record/association_matchers/model_reflector'
        autoload :ModelReflection, 'shoulda/matchers/active_record/association_matchers/model_reflection'
        autoload :OptionVerifier, 'shoulda/matchers/active_record/association_matchers/option_verifier'
      end
    end
  end
end
