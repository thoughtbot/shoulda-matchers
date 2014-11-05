require_relative 'helpers/active_model_helpers'
require_relative 'helpers/base_helpers'
require_relative 'helpers/command_helpers'
require_relative 'helpers/gem_helpers'
require_relative 'helpers/rails_version_helpers'
require_relative 'helpers/rspec_helpers'
require_relative 'helpers/ruby_version_helpers'
require_relative 'helpers/step_helpers'

module AcceptanceTests
  module Helpers
    def self.configure_example_group(example_group)
      example_group.include(self)

      example_group.before do
        fs.clean
      end
    end

    include ActiveModelHelpers
    include BaseHelpers
    include CommandHelpers
    include GemHelpers
    include RailsVersionHelpers
    include RspecHelpers
    include RubyVersionHelpers
    include StepHelpers
  end
end
