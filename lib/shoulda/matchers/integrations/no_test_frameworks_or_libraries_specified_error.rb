module Shoulda
  module Matchers
    module Integrations
      # @private
      class NoTestFrameworksOrLibrariesSpecifiedError < Shoulda::Matchers::Error
        protected

        def build_message
          <<-MESSAGE
shoulda-matchers is not configured correctly. You need to specify at least one
test framework and/or library. For example:

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec    # or, :minitest
    with.library :rails
  end
end
          MESSAGE
        end
      end
    end
  end
end
