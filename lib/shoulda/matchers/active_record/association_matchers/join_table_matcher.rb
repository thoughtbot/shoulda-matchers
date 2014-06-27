module Shoulda
  module Matchers
    module ActiveRecord
      module AssociationMatchers
        class JoinTableMatcher
          attr_accessor :missing_option

          def initialize(join_table, name)
          end

          def matches?(subject)
            self.subject = ModelReflector.new(subject, name)
          end

          private

          attr_accessor :subject, :name
        end
      end
    end
  end
end
