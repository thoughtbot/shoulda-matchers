module Shoulda
  module Matchers
    # @private
    def self.configure(&block)
      yield Configuration.new
    end

    # @private
    class Configuration
      def integrate(&block)
        configuration = Integrations::Configuration.new(&block)
        Integrations::ApplyConfiguration.call(configuration)
      end
    end
  end
end
