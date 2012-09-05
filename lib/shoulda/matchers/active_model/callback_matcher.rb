module Shoulda # :nodoc:
  module Matchers
    module ActiveModel # :nodoc:

      # Ensures that the model is not valid if the given attribute is not
      # present.
      #
      # Options:
      # * <tt>with_message</tt> - value the test expects to find in
      #   <tt>errors.on(:attribute)</tt>. <tt>Regexp</tt> or <tt>String</tt>.
      #   Defaults to the translation for <tt>:blank</tt>.
      #
      # Examples:
      #   it { should validate_presence_of(:name) }
      #   it { should validate_presence_of(:name).
      #                 with_message(/is not optional/) }
      #
      def callback(method)
        CallbackMatcher.new(method)
      end

      class CallbackMatcher # :nodoc:
        
        attr_reader :method, :hook, :lifecycle, :condition_type, :condition
        
        def initialize(method)
          @method = method
        end
        
        [:before, :after, :around].each do |hook|
          define_method hook do |lifecycle|
            @hook = hook
            @lifecycle = lifecycle

            self
          end
        end
        
        [:if, :unless].each do |condition_type|
          define_method condition_type do |condition|
            @condition_type = condition_type
            @condition = condition

            self
          end
        end

        def matches?(subject)
          callbacks = subject.send(:"_#{@lifecycle}_callbacks").dup
          callbacks.select!{|callback| callback.filter == @method && callback.kind == @hook && matches_conditions?(callback) }
          callbacks.size > 0
        end
        
        def failure_message
          "expected #{@method} to be listed as a callback #{@hook} #{@lifecycle}#{condition_phrase}, but was not"
        end
        
        def negative_failure_message
          "expected #{@method} not to be listed as a callback #{@hook} #{@lifecycle}#{condition_phrase}, but was"
        end

        def description
          "callback #{@method} #{@hook} #{@lifecycle}#{condition_phrase}"
        end

        private
          
          def matches_conditions?(callback)
            !@condition || callback.options[@condition_type].include?(@condition)
          end
          
          def condition_phrase
            " #{@condition_type} #{@condition} evaluates to #{@condition_type == :if ? 'true' : 'false'}" if @condition
          end

      end
    end
  end
end
