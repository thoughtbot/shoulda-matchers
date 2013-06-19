module Shoulda # :nodoc:
  module Matchers
    module ActiveRecord # :nodoc:
      module AssociationMatchers
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
            subject = ModelReflector.new(subject, name)

            if subject.option_set_properly?(counter_cache, :counter_cache)
              true
            else
              self.missing_option = "#{name} should have #{description}"
              false
            end
          end

          private
          attr_accessor :counter_cache, :name
        end
      end
    end
  end
end
