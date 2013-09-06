module Shoulda # :nodoc:
  module Matchers
    module ActiveModel # :nodoc:

      def self.possible_callback_pairs
        ::ActiveRecord::Base::CALLBACKS.collect{|symbol| symbol.to_s.split('_')}
      end

      possible_callback_pairs.each do |pair|
        when_occures = pair[0]
        action       = pair[1]

        define_method "have_#{when_occures}_#{action}_callback_on" do |method_name|
          Callbacks.new(when_occures, action, method_name)
        end
      end

      class Callbacks
        attr_reader :failure_message_for_should, :failure_message_for_should_not

        def initialize(occures, action, method_name)
          @occures = occures.to_sym
          @action  = action.to_sym
          @method_name = method_name.to_sym
        end

        def matches?(subject)
          @subject = subject
          if callbacks.include?(@method_name)
            @failure_message_for_should_not = "Didn't expect #{@subject.model_name} model to have #{callback_name} callback on method :#{@method_name}"
          else
            @failure_message_for_should     = "Expected #{@subject.model_name} model to have #{callback_name} callback on method :#{@method_name}"
            return false
          end
          true
        end

        def callbacks
          action_callbacks.select{|cb| cb.kind.eql?(@occures) }.collect(&:filter)
        end

        def action_callbacks
          begin
            @subject.send("_#{@action}_callbacks")
          rescue NoMethodError
            raise "Subject must be Rails model class"
          end
        end

        def callback_name
          "#{@occures}_#{@action}" 
        end
      end

    end
  end
end
