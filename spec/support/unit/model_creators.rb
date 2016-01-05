module UnitTests
  module ModelCreators
    class << self
      def register(name, klass)
        registrations[name] = klass
      end

      def retrieve(name)
        registrations[name]
      end

      private

      def registrations
        @_registrations ||= {}
      end
    end
  end
end
