module Shoulda
  module Matchers
    module ActiveRecord
      # The `accept_nested_attributes_for` matcher tests usage of the
      # `accepts_nested_attributes_for` macro.
      #
      #     class Car < ActiveRecord::Base
      #       accepts_nested_attributes_for :doors
      #     end
      #
      #     # RSpec
      #     describe Car do
      #       it { should accept_nested_attributes_for(:doors) }
      #     end
      #
      #     # Test::Unit (using Shoulda)
      #     class CarTest < ActiveSupport::TestCase
      #       should accept_nested_attributes_for(:doors)
      #     end
      #
      # #### Qualifiers
      #
      # ##### allow_destroy
      #
      # Use `allow_destroy` to assert that the `:allow_destroy` option was
      # specified.
      #
      #     class Car < ActiveRecord::Base
      #       accepts_nested_attributes_for :mirrors, allow_destroy: true
      #     end
      #
      #     # RSpec
      #     describe Car do
      #       it do
      #         should accept_nested_attributes_for(:mirrors).
      #           allow_destroy(true)
      #       end
      #     end
      #
      #     # Test::Unit
      #     class CarTest < ActiveSupport::TestCase
      #       should accept_nested_attributes_for(:mirrors).
      #         allow_destroy(true)
      #     end
      #
      # ##### limit
      #
      # Use `limit` to assert that the `:limit` option was specified.
      #
      #     class Car < ActiveRecord::Base
      #       accepts_nested_attributes_for :windows, limit: 3
      #     end
      #
      #     # RSpec
      #     describe Car do
      #       it do
      #         should accept_nested_attributes_for(:windows).
      #           limit(3)
      #       end
      #     end
      #
      #     # Test::Unit
      #     class CarTest < ActiveSupport::TestCase
      #       should accept_nested_attributes_for(:windows).
      #         limit(3)
      #     end
      #
      # ##### update_only
      #
      # Use `update_only` to assert that the `:update_only` option was
      # specified.
      #
      #     class Car < ActiveRecord::Base
      #       accepts_nested_attributes_for :engine, update_only: true
      #     end
      #
      #     # RSpec
      #     describe Car do
      #       it do
      #         should accept_nested_attributes_for(:engine).
      #           update_only(true)
      #       end
      #     end
      #
      #     # Test::Unit
      #     class CarTest < ActiveSupport::TestCase
      #       should accept_nested_attributes_for(:engine).
      #         update_only(true)
      #     end
      #
      # ##### reject_if
      #
      # Use `reject_if` to assert that the `:reject_if` option was
      # specified.
      #
      #     class Car < ActiveRecord::Base
      #       accepts_nested_attributes_for :engine, reject_if: :all_blank
      #     end
      #
      #     # RSpec
      #     describe Car do
      #       it do
      #         should accept_nested_attributes_for(:engine).
      #           reject_if(:all_blank)
      #       end
      #     end
      #
      #     # Test::Unit
      #     class CarTest < ActiveSupport::TestCase
      #       should accept_nested_attributes_for(:engine).
      #         reject_if(:all_blank)
      #     end
      #
      # ###### Caveat
      #
      # Since we are not capable to compare a Proc unless they are exactly the same object,
      # the qualifier accepts only symbol as parameter.
      #
      # @return [AcceptNestedAttributesForMatcher]
      #
      def accept_nested_attributes_for(name)
        AcceptNestedAttributesForMatcher.new(name)
      end

      # @private
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

        def reject_if(reject_if)
          @options[:reject_if] = reject_if
          self
        end

        def matches?(subject)
          @subject = subject
          exists? &&
            allow_destroy_correct? &&
            limit_correct? &&
            update_only_correct? &&
            reject_if_correct?
        end

        def failure_message
          "Expected #{expectation} (#{@problem})"
        end
        alias failure_message_for_should failure_message

        def failure_message_when_negated
          "Did not expect #{expectation}"
        end
        alias failure_message_for_should_not failure_message_when_negated

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
          if @options.key?(:reject_if)
            description += " reject_if => #{@options[:reject_if]}"
          end
          description
        end

        protected

        def exists?
          if config
            true
          else
            @problem = 'is not declared'
            false
          end
        end

        def allow_destroy_correct?
          failure_message = "#{should_or_should_not(@options[:allow_destroy])} allow destroy"
          verify_option_is_correct(:allow_destroy, failure_message)
        end

        def limit_correct?
          failure_message = "limit should be #{@options[:limit]}, got #{config[:limit]}"
          verify_option_is_correct(:limit, failure_message)
        end

        def update_only_correct?
          failure_message = "#{should_or_should_not(@options[:update_only])} be update only"
          verify_option_is_correct(:update_only, failure_message)
        end

        def reject_if_correct?
          failure_message = "reject_if #{should_or_should_not(@options[:reject_if])} be :#{@options[:reject_if]}, got "

          if reject_if_option_is_a_callable?
            message = "You need to use a symbol as reject_if param"
            raise ArgumentError, message
          elsif reject_if_all_blank_matches?
            true
          elsif reject_if_config_is_equals_a_proc?
            failure_message << ":all_blank"
            @problem = failure_message
            false
          else
            failure_message << ":#{config[:reject_if]}"
            verify_option_is_correct(:reject_if, failure_message)
          end
        end

        def reject_if_option_is_a_callable?
          @options[:reject_if].respond_to?(:call)
        end

        def reject_if_config_is_equals_a_proc?
          Proc === config[:reject_if]
        end

        def reject_if_all_blank_matches?
          @options[:reject_if] == :all_blank && reject_if_config_is_equals_a_proc?
        end

        def trying_to_compare_symbol_with_proc?
          @options[:reject_if].is_a?(Symbol) && reject_if_config_is_equals_a_proc?
        end

        def verify_option_is_correct(option, failure_message)
          if @options.key?(option)
            if @options[option] == config[option]
              true
            else
              @problem = failure_message
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

        def should_or_should_not(value)
          if value
            'should'
          else
            'should not'
          end
        end
      end
    end
  end
end
