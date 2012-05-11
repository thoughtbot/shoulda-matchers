module Shoulda
  module Matchers
    module ActiveRecord
      # Ensures that the model can accept nested attributes for the specified
      # association.
      #
      # Options:
      # * <tt>allow_destroy</tt> - Whether or not to allow destroy
      # * <tt>limit</tt> - Max number of nested attributes
      # * <tt>update_only</tt> - Only allow updates
      #
      # Example:
      #   it { should accept_nested_attributes_for(:friends) }
      #   it { should accept_nested_attributes_for(:friends).
      #                 allow_destroy(true).
      #                 limit(4) }
      #   it { should accept_nested_attributes_for(:friends).
      #                 update_only(true) }
      #
      def accept_nested_attributes_for(name)
        AcceptNestedAttributesForMatcher.new(name)
      end

      class AcceptNestedAttributesForMatcher
        def initialize(name)
          @name = name
          @options = {}
        end

        def allow_destroy(allow_destroy)
          @options[:allow_destroy] = allow_destroy
          self
        end

        def limit(limit)
          @options[:limit] = limit
          self
        end

        def update_only(update_only)
          @options[:update_only] = update_only
          self
        end

        def matches?(subject)
          @subject = subject
          exists? &&
            allow_destroy_correct? &&
            limit_correct? &&
            update_only_correct?
        end

        def failure_message
          "Expected #{expectation} (#{@problem})"
        end

        def negative_failure_message
          "Did not expect #{expectation}"
        end

        def description
          description = "accepts_nested_attributes_for :#{@name}"
          if @options.key?(:allow_destroy)
            description += " allow_destroy => #{@options[:allow_destroy]}"
          end
          if @options.key?(:limit)
            description += " limit => #{@options[:limit]}"
          end
          if @options.key?(:update_only)
            description += " update_only => #{@options[:update_only]}"
          end
          description
        end

        protected

        def exists?
          if config
            true
          else
            @problem = "is not declared"
            false
          end
        end

        def allow_destroy_correct?
          if @options.key?(:allow_destroy)
            if @options[:allow_destroy] == config[:allow_destroy]
              true
            else
              @problem = (@options[:allow_destroy] ? "should" : "should not") +
                " allow destroy"
              false
            end
          else
            true
          end
        end

        def limit_correct?
          if @options.key?(:limit)
            if @options[:limit] == config[:limit]
              true
            else
              @problem = "limit should be #{@options[:limit]}, got #{config[:limit]}"
              false
            end
          else
            true
          end
        end

        def update_only_correct?
          if @options.key?(:update_only)
            if @options[:update_only] == config[:update_only]
              true
            else
              @problem = (@options[:update_only] ? "should" : "should not") +
                " be update only"
              false
            end
          else
            true
          end
        end

        def config
          model_config[@name]
        end

        def model_config
          model_class.nested_attributes_options
        end

        def model_class
          @subject.class
        end

        def expectation
          "#{model_class.name} to accept nested attributes for #{@name}"
        end
      end
    end
  end
end
