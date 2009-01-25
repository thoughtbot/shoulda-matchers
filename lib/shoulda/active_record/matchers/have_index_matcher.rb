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
      def have_index(index)
        HaveIndexMatcher.new(:have_index, index)
      end

      class HaveIndexMatcher # :nodoc:
        def initialize(macro, index)
          @macro = macro
          @index = normalize_index_to_array(index)
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
          "have index named #{@column}"
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
            @missing = "#{model_class} has an index named #{matched_index.name} " <<
                       "of unique #{matched_index.unique}, not #{@unique}."
            false
          end
        end
        
        def matched_index
          indexes.detect { |each| each.columns == @index }
        end

        def model_class
          @subject.class
        end
        
        def indexes
          ::ActiveRecord::Base.connection.indexes(model_class.table_name)
        end

        def expectation
          expected = "#{model_class.name} to #{description}"
        end
        
        def normalize_index_to_array(index)
          if index.class == Array
            index.collect { |each| each.to_s }
          else
            [index.to_s]
          end
        end
      end

    end
  end
end
