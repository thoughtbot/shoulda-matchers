module Shoulda # :nodoc:
  module Matchers
    module ActiveRecord # :nodoc:
      module AssociationMatchers
        class OrderMatcher
          attr_accessor :missing_option

          def initialize(order, name)
            @order = order
            @name = name
            @missing_option = ''
          end

          def description
            "order => #{order}"
          end

          def matches?(subject)
            subject = ModelReflector.new(subject, name)

            if subject.option_set_properly?(order, :order)
              true
            else
              self.missing_option = "#{name} should be ordered by #{order}"
              false
            end
          end

          private
          attr_accessor :order, :name
        end
      end
    end
  end
end
