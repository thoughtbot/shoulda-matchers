module AcceptanceTests
  module ActiveModelHelpers
    def active_model_version
      Bundler.definition.specs['activemodel'][0].version
    end
  end
end
