module Shoulda # :nodoc:
  module Matchers
    module ActiveRecord # :nodoc:
      module AssociationMatchers
        class JoinTableMatcher
          attr_reader :association_matcher, :failure_message
          alias :missing_option :failure_message

          delegate :model_class, :join_table, :associated_class,
            to: :association_matcher

          delegate :connection, to: :model_class

          def initialize(association_matcher)
            @association_matcher = association_matcher
          end

          def matches?(subject)
            join_table_exists? &&
              join_table_has_correct_columns?
          end

          def join_table_exists?
            if connection.tables.include?(join_table)
              true
            else
              @failure_message = missing_table_message
              false
            end
          end

          def join_table_has_correct_columns?
            if missing_columns.empty?
              true
            else
              @failure_message = missing_columns_message
              false
            end
          end

          private

          def missing_columns
            @missing_columns ||= expected_join_table_columns.select do |key|
              !actual_join_table_columns.include?(key)
            end
          end

          def expected_join_table_columns
            [
              "#{model_class.name.underscore}_id",
              "#{associated_class.name.underscore}_id"
            ]
          end

          def actual_join_table_columns
            connection.columns(join_table).map(&:name)
          end

          def missing_table_message
            "join table #{join_table} doesn't exist"
          end

          def missing_columns_message
            missing = missing_columns.join(', ')
            "join table #{join_table} missing #{column_label}: #{missing}"
          end

          def column_label
            if missing_columns.count > 1
              'columns'
            else
              'column'
            end
          end
        end
      end
    end
  end
end
