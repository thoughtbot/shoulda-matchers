module Shoulda
  module Matchers
    # @private
    class Error < StandardError
      def self.create(attributes)
        allocate.tap do |error|
          attributes.each do |name, value|
            error.__send__("#{name}=", value)
          end

          error.__send__(:initialize)
        end
      end

      def initialize(*args)
        if respond_to?(:build_message)
          message = build_message
        else
          message = self.message
        end

        formatted_message = Shoulda::Matchers.word_wrap(message).
          sub(/\A\s*/, "\n\n").
          sub(/\s*\Z/, "\n\n")

        super(formatted_message)
      end

      def inspect
        %(#<#{self.class}: #{message}>)
      end

      private

      def build_message
        ""
      end
    end
  end
end
