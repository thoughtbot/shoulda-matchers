module Shoulda
  module Matchers
    module ActiveRecord
      # The `have_implicit_order_column` matcher tests that the model has `implicit_order_column`
      # assigned to one of the table columns. (Rails 6+ only)
      #
      #     class Product < ApplicationRecord
      #       self.implicit_order_column = :created_at
      #     end
      #
      #     # RSpec
      #     RSpec.describe Product, type: :model do
      #       it { should have_implicit_order_column(:created_at) }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class ProductTest < ActiveSupport::TestCase
      #       should have_implicit_order_column(:created_at)
      #     end
      #
      # @return [HaveImplicitOrderColumnMatcher]
      #
      if RailsShim.active_record_gte_6?
        def have_implicit_order_column(column)
          HaveImplicitOrderColumnMatcher.new(column)
        end
      end

      # @private
      class HaveImplicitOrderColumnMatcher
        def initialize(column)
          @column = column
        end

        def matches?(subject)
          @subject = subject
          column_exists? && implicit_order_column_matches?
        end

        def failure_message
          "Expected #{expectation} (#{@details})"
        end

        def failure_message_when_negated
          "Did not expect #{expectation}"
        end

        def description
          "have implicit_order_column assigned to #{@column}"
        end

        private

        def column_exists?
          matcher = HaveDbColumnMatcher.new(@column)

          if matcher.matches?(@subject)
            true
          else
            @details = "#{model_class} does not have a db column named #{@column}"
            false
          end
        end

        def implicit_order_column_matches?
          model_implicit_order_column = model_class.implicit_order_column

          if model_implicit_order_column.to_s == @column.to_s
            true
          else
            @details = if model_implicit_order_column.nil?
                         "#{model_class} implicit_order_column is not set"
                       else
                         "#{model_class} implicit_order_column is " +
                           "set to #{model_implicit_order_column}"
                       end
            false
          end
        end

        def model_class
          @subject.class
        end

        def expectation
          "#{model_class.name} to have implicit_order_column set to #{@column}"
        end
      end
    end
  end
end
