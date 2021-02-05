require_relative 'gem_helpers'

module AcceptanceTests
  module ActiveRecordHelpers
    include GemHelpers

    def active_record_version
      bundle_version_of('activerecord')
    end
  end
end
