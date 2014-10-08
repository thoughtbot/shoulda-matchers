module Shoulda
  module Matchers
    # @private
    module Util
      def self.deconstantize(path)
        if defined?(ActiveSupport::Inflector) &&
          ActiveSupport::Inflector.respond_to?(:deconstantize)
          ActiveSupport::Inflector.deconstantize(path)
        else
          path.to_s[0...(path.to_s.rindex('::') || 0)]
        end
      end
    end
  end
end
