module Shoulda # :nodoc:
  module ActiveRecord # :nodoc:
    module Matchers

      # Ensures the database column has specified index.
      #
      # Options:
      # * <tt>unique</tt> - 
      #
      # Example:
      #   it { should have_index(:ssn).unique(true) }
      #
      def have_index(columns)
        HaveIndexMatcher.new(:have_index, columns)
      end

      class HaveIndexMatcher # :nodoc:
        def initialize(macro, columns)
          @macro = macro
          @columns = normalize_columns_to_array(columns)
        end
        
        def unique(unique)
          @unique = unique
          self
        end

        def matches?(subject)
          @subject = subject
          index_exists? && correct_unique?
        end

        def failure_message
          "Expected #{expectation} (#{@missing})"
        end

        def negative_failure_message
          "Did not expect #{expectation}"
        end

        def description
          "have a #{index_type} index on columns #{@columns}"
        end

        protected
        
        def index_exists?
          ! matched_index.nil?
        end
        
        def correct_unique?
          return true if @unique.nil?
          if matched_index.unique == @unique
            true
          else
            @missing = "#{table_name} has an index named #{matched_index.name} " <<
                       "of unique #{matched_index.unique}, not #{@unique}."
            false
          end
        end
        
        def matched_index
          indexes.detect { |each| each.columns == @columns }
        end

        def model_class
          @subject.class
        end
        
        def table_name
          model_class.table_name
        end
        
        def indexes
          ::ActiveRecord::Base.connection.indexes(table_name)
        end

        def expectation
          expected = "#{model_class.name} to #{description}"
        end
        
        def index_type
          @unique ? "unique" : "non-unique"
        end
        
        def normalize_columns_to_array(columns)
          if columns.class == Array
            columns.collect { |each| each.to_s }
          else
            [columns.to_s]
          end
        end
      end

    end
  end
end
