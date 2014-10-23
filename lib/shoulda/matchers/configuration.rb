module Shoulda
  module Matchers
    # @private
    def self.configure
      yield configuration
    end

    # @private
    def self.configuration
      @_configuration ||= Configuration.new
    end

    # @private
    class Configuration
      def integrate(&block)
        Integrations::Configuration.apply(self, &block)
      end
    end
  end
end
