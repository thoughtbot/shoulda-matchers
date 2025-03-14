module Shoulda
  module Matchers
    module ActiveRecord
      module AssociationMatchers
        # @private
        class CounterCacheMatcher
          attr_accessor :missing_option

          def initialize(counter_cache, name)
            @counter_cache = counter_cache
            @name = name
            @missing_option = ''
          end

          def description
            "counter_cache => #{counter_cache}"
          end

          def matches?(subject)
            self.subject = ModelReflector.new(subject, name)

            if correct_value?
              true
            else
              self.missing_option = "#{name} should have #{description}"
              false
            end
          end

          protected

          attr_accessor :subject, :counter_cache, :name

          def correct_value?
            expected = normalize_value

            if expected.is_a?(Hash)
              option_verifier.correct_for_hash?(
                :counter_cache,
                expected,
              )
            else
              option_verifier.correct_for_string?(
                :counter_cache,
                expected,
              )
            end
          end

          def option_verifier
            @_option_verifier ||= OptionVerifier.new(subject)
          end

          def normalize_value
            if Rails::VERSION::STRING >= '7.2'
              case counter_cache
              when true
                { active: true, column: nil }
              when String, Symbol
                { active: true, column: counter_cache.to_s }
              when Hash
                { active: true, column: nil }.merge!(counter_cache)
              else
                raise ArgumentError, 'Invalid counter_cache option'
              end
            else
              counter_cache
            end
          end
        end
      end
    end
  end
end
