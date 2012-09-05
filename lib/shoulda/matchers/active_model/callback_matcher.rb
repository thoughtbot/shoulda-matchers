module Shoulda # :nodoc:
  module Matchers
    module ActiveModel # :nodoc:

      # Ensures that the given model has a callback defined for the given method
      #
      # Options:
      # * <tt>before(:lifecycle)</tt>. <tt>Symbol</tt>. - define the callback as a callback before the fact. :lifecycle can be :save, :create, :update, :destroy, :validation
      # * <tt>after(:lifecycle)</tt>. <tt>Symbol</tt>. - define the callback as a callback after the fact. :lifecycle can be :save, :create, :update, :destroy, :validation, :initialize, :find, :touch
      # * <tt>around(:lifecycle)</tt>. <tt>Symbol</tt>. - define the callback as a callback around the fact. :lifecycle can be :save, :create, :update, :destroy
      #   <tt>if(:condition)</tt>. <tt>Symbol</tt>. - add a positive condition to the callback to be matched against
      #   <tt>unless(:condition)</tt>. <tt>Symbol</tt>. - add a negative condition to the callback to be matched against
      #
      # Examples:
      #   it { should callback(:method).after(:create) }
      #   it { should callback(:method).before(:validation).unless(:should_it_not?) }
      #
      def callback(method)
        CallbackMatcher.new(method)
      end

      class CallbackMatcher # :nodoc:
                
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
          unless @lifecycle
            @failure_message = "callback #{@method} can not be tested against an undefined lifecycle, use .before, .after or .around"
            false
          else
            callbacks = subject.send(:"_#{@lifecycle}_callbacks").dup
            callbacks.select!{|callback| callback.filter == @method && callback.kind == @hook && matches_conditions?(callback) }
            callbacks.size > 0
          end
        end
        
        def failure_message
          @failure_message || "expected #{@method} to be listed as a callback #{@hook} #{@lifecycle}#{condition_phrase}, but was not"
        end
        
        def negative_failure_message
          @failure_message || "expected #{@method} not to be listed as a callback #{@hook} #{@lifecycle}#{condition_phrase}, but was"
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
