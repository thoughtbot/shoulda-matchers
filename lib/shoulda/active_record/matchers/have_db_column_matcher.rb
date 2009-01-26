module Shoulda # :nodoc:
  module ActiveRecord # :nodoc:
    module Matchers

      # Ensures the database column exists.
      #
      # Options:
      # * <tt>of_type</tt> - db column type (:integer, :string, etc.)
      # * <tt>with_options</tt> - same options available in migrations
      #   (:default, :null, :limit, :precision, :scale)
      #
      # Examples:
      #   it { should_not have_db_column(:admin).of_type(:boolean) }
      #   it { should have_db_column(:salary).
      #                 of_type(:decimal).
      #                 with_options(:precision => 10, :scale => 2) }
      #
      def have_db_column(column)
        HaveDbColumnMatcher.new(:have_db_column, column)
      end

      class HaveDbColumnMatcher # :nodoc:
        def initialize(macro, column)
          @macro  = macro
          @column = column
        end
        
        def of_type(column_type)
          @column_type = column_type
          self
        end
        
        def with_options(opts = {})
          @precision = opts[:precision]
          @limit     = opts[:limit]
          @default   = opts[:default]
          @null      = opts[:null]
          @scale     = opts[:scale]
          self
        end

        def matches?(subject)
          @subject = subject
          column_exists? && 
            correct_column_type? && 
            correct_precision? &&
            correct_limit? &&
            correct_default? &&
            correct_null? &&
            correct_scale?
        end

        def failure_message
          "Expected #{expectation} (#{@missing})"
        end

        def negative_failure_message
          "Did not expect #{expectation}"
        end

        def description
          desc = "have db column named #{@column}"
          desc << " of type #{@column_type}"    unless @column_type.nil?
          desc << " of precision #{@precision}" unless @precision.nil?
          desc << " of limit #{@limit}"         unless @limit.nil?
          desc << " of default #{@default}"     unless @default.nil?
          desc << " of null #{@null}"           unless @null.nil?
          desc << " of primary #{@primary}"     unless @primary.nil?
          desc << " of scale #{@scale}"         unless @scale.nil?
          desc
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
                
        def correct_scale?
          return true if @scale.nil?
          if matched_column.scale.to_s == @scale.to_s
            true
          else
            @missing = "#{model_class} has a db column named #{@column} " <<
                       "of scale #{matched_column.scale}, not #{@scale}."
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
          expected = "#{model_class.name} to #{description}"
        end
      end

    end
  end
end
