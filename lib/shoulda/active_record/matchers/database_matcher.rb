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
        
        def default(default)
          @default = default
          self
        end
        
        def null(null)
          @null = null
          self
        end

        def matches?(subject)
          @subject = subject
          column_exists? && 
            correct_column_type? && 
            correct_precision? &&
            correct_limit? &&
            correct_default? &&
            correct_null?
        end

        def failure_message
          "Expected #{expectation} (#{@missing})"
        end

        def negative_failure_message
          "Did not expect #{expectation}"
        end

        def description
          "has db column #{@column}"
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
          return true if @column_type.nil?
          if matched_column.type.to_s == @column_type.to_s
            true
          else
            @missing = "#{model_class} has a db column named #{@column} " <<
                       "of type #{matched_column.type}, not #{@column_type}."
            false
          end
        end
        
        def correct_precision?
          return true if @precision.nil?
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
          return true if @limit.nil?
          if matched_column.limit.to_s == @limit.to_s
            true
          else
            @missing = "#{model_class} has a db column named #{@column} " <<
                       "of limit #{matched_column.limit}, " <<
                       "not #{@limit}."
            false
          end
        end
        
        def correct_default?
          return true if @default.nil?
          if matched_column.default.to_s == @default.to_s
            true
          else
            @missing = "#{model_class} has a db column named #{@column} " <<
                       "of default #{matched_column.default}, " <<
                       "not #{@default}."
            false
          end
        end
        
        def correct_null?
          return true if @null.nil?
          if matched_column.null.to_s == @null.to_s
            true
          else
            @missing = "#{model_class} has a db column named #{@column} " <<
                       "of null #{matched_column.null}, " <<
                       "not #{@null}."
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
          "#{model_class.name} to have db column named #{@column}"
        end
      end

      def has_db_column(column)
        DatabaseMatcher.new(:has_db_column, column)
      end

    end
  end
end
