module Shoulda
  module Matchers
    module ActiveRecord
      # The `have_implicit_order_column` matcher tests that the model has
      # `implicit_order_column` assigned to one of the table columns.
      # (Rails 6+ only.)
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
          message =
            if details
              "Expected #{expectation} (#{details})."
            else
              "Expected #{expectation}."
            end

          Shoulda::Matchers.word_wrap(message)
        end

        def failure_message_when_negated
          Shoulda::Matchers.word_wrap(
            "Did not expect #{expectation}, but it did.",
          )
        end

        def description
          "have an implicit_order_column of :#{column}"
        end

        private

        attr_reader :column, :subject, :details

        def column_exists?
          matcher = HaveDbColumnMatcher.new(column)

          if matcher.matches?(subject)
            true
          else
            @details =
              "#{model.table_name} does not have #{a_or_an(":#{column}")} " +
              'column'
            false
          end
        end

        def implicit_order_column_matches?
          model_implicit_order_column = model.implicit_order_column

          if model_implicit_order_column.to_s == column.to_s
            true
          else
            @details =
              if model_implicit_order_column
                'its implicit_order_column is ' +
                  ":#{model_implicit_order_column}"
              else
                'it does not have an implicit_order_column'
              end
            false
          end
        end

        def expectation
          "#{model.name} to have an implicit_order_column of :#{column}"
        end

        def model
          subject.class
        end

        def a_or_an(word)
          Shoulda::Matchers::Util.a_or_an(word)
        end
      end
    end
  end
end
