module Shoulda # :nodoc:
  module ActiveRecord # :nodoc:
    module Matchers # :nodoc:

      class DatabaseMatcher
        def initialize(macro, column)
          @macro       = macro
          @column      = column
        end
        
        def column_type(column_type)
          @column_type = column_type
          self
        end
        
        def precision(precision)
          @precision = precision
          self
        end
        
        def limit(limit)
          @limit = limit
          self
        end

        def matches?(subject)
          @subject = subject
          column_exists? && 
            correct_column_type? && 
            correct_precision? &&
            correct_limit?
        end

        def failure_message
          "Expected #{expectation}"
        end

        def negative_failure_message
          "Did not expect #{expectation}"
        end

        def description
          "#{macro_description} #{@column}"
        end

        protected

        def column_exists?
          if model_class.column_names.include?(@column.to_s)
            true
          else
            @missing = "#{model_class} does not have a db column named #{@column}."
            false
          end
        end
        
        def correct_column_type?
          return true unless @column_type
          if matched_column.type.to_s == @column_type.to_s
            true
          else
            @missing = "#{model_class} has a db column named #{@column} " <<
                       "of type #{matched_column.type}, not #{@column_type}."
            false
          end
        end
        
        def correct_precision?
          return true unless @precision
          if matched_column.precision.to_s == @precision.to_s
            true
          else
            @missing = "#{model_class} has a db column named #{@column} " <<
                       "of precision #{matched_column.precision}, " <<
                       "not #{@precision}."
            false
          end
        end
        
        def correct_limit?
          return true unless @limit
          if matched_column.limit.to_s == @limit.to_s
            true
          else
            @missing = "#{model_class} has a db column named #{@column} " <<
                       "of limit #{matched_column.limit}, " <<
                       "not #{@limit}."
            false
          end
        end
        
        def matched_column
          model_class.columns.detect { |each| each.name == @column.to_s }
        end

        def model_class
          @subject.class
        end

        def expectation
          "#{model_class.name} to have a db column named #{@column}"
        end
        
        def macro_description
          case @macro.to_s
          when 'has_db_column' then 'has db column'
          end
        end
      end

      def has_db_column(column)
        DatabaseMatcher.new(:has_db_column, column)
      end

    end
  end
end
