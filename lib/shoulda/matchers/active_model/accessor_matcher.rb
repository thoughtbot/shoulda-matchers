module Shoulda # :nodoc:
  module Matchers
    module ActiveModel # :nodoc:

      # Ensures that the attribute defined through an attr_*
      # class method has the appropriate generated methods
      #
      # Example:
      #   it { should have_accessor(:field) }
      #   it { should have_reader(:field) }
      #   it { should have_writer(:field) }
      #

      def have_accessor(attribute)
        have_methods(:accessor, attribute)
      end

      def have_reader(attribute)
        have_methods(:reader, attribute)
      end

      def have_writer(attribute)
        have_methods(:writer, attribute)
      end

      def have_methods(macro, attribute)
        if attribute.blank?
          raise ArgumentError, "need attribute"
        else
          AccessorMatcher.new(macro, attribute)
        end
      end

      class AccessorMatcher # :nodoc:
        attr_reader :failure_message

        def initialize(macro, attribute)
          @macro = macro
          @attribute = attribute
        end

        def matches?(subject)
          @subject = subject
          (writer_only? || reader_exists?) &&
            (reader_only? || writer_exists?)
        end

        def model_class
          @subject.class
        end

        def instance
          model_class.new
        end

        def writer_only?
          @macro == :writer
        end

        def reader_only?
          @macro == :reader
        end

        def reader_exists?
          method_exists?(@attribute)
        end

        def writer_exists?
          method_exists?("#{@attribute}=".to_sym)
        end

        def method_exists?(method)
          if instance.respond_to?(method)
            true
          else
            @failure_message = "#{model_class.name} does not have method '#{method}'"
            false
          end
        end

        def description
          "have #{macro_description} for #{@attribute}"
        end

        def macro_description
          case @macro.to_s
          when 'accessor'
            'reader and writer methods'
          when 'reader'
            'a reader method'
          when 'writer'
            'a writer method'
          end
        end
      end
    end
  end
end