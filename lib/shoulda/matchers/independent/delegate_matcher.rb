module Shoulda # :nodoc:
  module Matchers
    module Independent # :nodoc:

      # Ensure that a given method is delegated properly.
      #
      # Basic Syntax:
      #   it { should delegate_method(:deliver_mail).to(:mailman) }
      #
      # Options:
      # * <tt>:as</tt> - tests that the object being delegated to is called
      #    with a certain method (defaults to same name as delegating method)
      # * <tt>:with_arguments</tt> - tests that the method on the object being
      #   delegated to is called with certain arguments
      #
      # Examples:
      #   it { should delegate_method(:deliver_mail).to(:mailman).
      #     as(:deliver_with_haste) }
      #   it { should delegate_method(:deliver_mail).to(:mailman).
      #     with_arguments('221B Baker St.', :hastily => true) }
      #
      def delegate_method(delegating_method)
        DelegateMatcher.new(delegating_method)
      end

      class DelegateMatcher
        def initialize(delegating_method)
          @delegating_method = delegating_method
          @delegated_arguments = []
        end

        def matches?(_subject)
          @subject = _subject
          ensure_target_method_is_present!
          stub_target

          begin
            subject.send(delegating_method, *delegated_arguments)
            target_has_received_delegated_method? && target_has_received_arguments?
          rescue NoMethodError
            false
          end
        end

        def description
          add_clarifications_to(
            "delegate method ##{delegating_method} to :#{target_method}"
          )
        end

        def does_not_match?(subject)
          raise InvalidDelegateMatcher
        end

        def to(target_method)
          @target_method = target_method
          self
        end

        def as(method_on_target)
          @method_on_target = method_on_target
          self
        end

        def with_arguments(*arguments)
          @delegated_arguments = arguments
          self
        end

        def failure_message
          base = "Expected #{delegating_method_name} to delegate to #{target_method_name}"
          add_clarifications_to(base)
        end
        alias failure_message_for_should failure_message

        private

        attr_reader :delegated_arguments, :delegating_method, :method, :subject,
          :target_method, :method_on_target

        def add_clarifications_to(message)
          if delegated_arguments.present?
            message << " with arguments: #{delegated_arguments.inspect}"
          end

          if method_on_target.present?
            message << " as ##{method_on_target}"
          end

          message
        end

        def delegating_method_name
          method_name_with_class(delegating_method)
        end

        def target_method_name
          method_name_with_class(target_method)
        end

        def method_name_with_class(method)
          if Class === subject
            subject.name + '.' + method.to_s
          else
            subject.class.name + '#' + method.to_s
          end
        end

        def target_has_received_delegated_method?
          stubbed_target.has_received_method?
        end

        def target_has_received_arguments?
          stubbed_target.has_received_arguments?(*delegated_arguments)
        end

        def stubbed_method
          method_on_target || delegating_method
        end

        def stub_target
          local_stubbed_target = stubbed_target
          local_target_method = target_method

          subject.instance_eval do
            define_singleton_method local_target_method do
              local_stubbed_target
            end
          end
        end

        def stubbed_target
          @stubbed_target ||= StubbedTarget.new(stubbed_method)
        end

        def ensure_target_method_is_present!
          if target_method.blank?
            raise TargetNotDefinedError
          end
        end
      end

      class DelegateMatcher::TargetNotDefinedError < StandardError
        def message
          'Delegation needs a target. Use the #to method to define one, e.g.
          `post_office.should delegate(:deliver_mail).to(:mailman)`'.squish
        end
      end

      class DelegateMatcher::InvalidDelegateMatcher < StandardError
        def message
          '#delegate_to does not support #should_not syntax.'
        end
      end
    end
  end
end
