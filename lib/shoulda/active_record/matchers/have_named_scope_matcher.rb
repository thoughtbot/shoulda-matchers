module Shoulda # :nodoc:
  module ActiveRecord # :nodoc:
    module Matchers

      class HaveNamedScopeMatcher # :nodoc:

        def initialize(scope_call)
          @scope_call = scope_call.to_s
        end

        def finding(finding)
          @finding = finding
          self
        end

        def in_context(context)
          @context = context
          self
        end

        def matches?(subject)
          @subject = subject
          call_succeeds? && returns_scope? && finds_correct_scope?
        end

        def failure_message
          "Expected #{@missing_expectation}"
        end

        def negative_failure_message
          "Didn't expect a named scope for #{@scope_call}"
        end

        def description
          result = "have a named scope for #{@scope_call}"
          result << " finding #{@finding.inspect}" unless @finding.nil?
          result
        end

        private

        def call_succeeds?
          scope
          true
        rescue Exception => exception
          @missing_expectation = "#{@subject.class.name} " <<
            "to respond to #{@scope_call} " <<
            "but raised error: #{exception.inspect}"
          false
        end

        def scope
          @scope ||= @context.instance_eval("#{@subject.class.name}.#{@scope_call}")
        end

        def returns_scope?
          if ::ActiveRecord::NamedScope::Scope === scope
            true
          else
            @missing_expectation = "#{@scope_call} to return a scope"
            false
          end
        end

        def finds_correct_scope?
          return true if @finding.nil?
          if @finding == scope.proxy_options
            true
          else
            @missing_expectation = "#{@scope_call} to return results scoped to "
            @missing_expectation << "#{@finding.inspect} but was scoped to "
            @missing_expectation << scope.proxy_options.inspect
            false
          end
        end

      end

      def have_named_scope(scope_call)
        HaveNamedScopeMatcher.new(scope_call).in_context(self)
      end

    end
  end
end
