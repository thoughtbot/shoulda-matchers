module Shoulda
  module Matchers
    module ActiveRecord
      module AssociationMatchers
        class JoinTableMatcher
          attr_accessor :missing_option

          def initialize(join_table, name)
            @join_table = join_table
            @name = name
            @missing_option = ''
          end

          def matches?(subject)
            self.subject = ModelReflector.new(subject, name)

            if option_verifier.correct_for_string?(:join_table, join_table)
              true
            else
              self.missing_option =
                "Expected to find join table called #{join_table}"
              false
            end
          end

          private

          attr_accessor :join_table, :subject, :name

          def option_verifier
            @option_verifier ||= OptionVerifier.new(subject)
          end
        end
      end
    end
  end
end
