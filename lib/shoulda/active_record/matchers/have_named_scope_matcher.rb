module Shoulda # :nodoc:
  module ActiveRecord # :nodoc:
    module Matchers

      # Ensures that the model has a method named scope_call that returns a
      # NamedScope object with the proxy options set to the options you supply.
      # scope_call can be either a symbol, or a Ruby expression in a String
      # which will be evaled. The eval'd method call has access to all the same
      # instance variables that an example would.
      #
      # Options:
      #
      #  * <tt>in_context</tt> - Any of the options that the named scope would
      #    pass on to find.
      #
      # Example:
      #
      #   it { should have_named_scope(:visible).
      #                 finding(:conditions => {:visible => true}) }
      #
      # Passes for
      #
      #   named_scope :visible, :conditions => {:visible => true}
      #
      # Or for
      #
      #   def self.visible
      #     scoped(:conditions => {:visible => true})
      #   end
      #
      # You can test lambdas or methods that return ActiveRecord#scoped calls:
      #
      #   it { should have_named_scope('recent(5)').finding(:limit => 5) }
      #   it { should have_named_scope('recent(1)').finding(:limit => 1) }
      #
      # Passes for
      #   named_scope :recent, lambda {|c| {:limit => c}}
      #
      # Or for
      #
      #   def self.recent(c)
      #     scoped(:limit => c)
      #   end
      #
      def have_named_scope(scope_call)
        HaveNamedScopeMatcher.new(scope_call).in_context(self)
      end

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

    end
  end
end
