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
          @index = index
        end

        def matches?(subject)
          @subject = subject
          index_exists?
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
        
        def matched_index
          indexes.detect { |each| each.columns.include?(@index.to_s) }
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
      end

    end
  end
end
