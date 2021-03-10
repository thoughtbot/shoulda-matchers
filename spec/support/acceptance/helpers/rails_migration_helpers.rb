require_relative 'gem_helpers'

module AcceptanceTests
  module RailsMigrationHelpers
    include RailsVersionHelpers

    def migration_class_name
      "ActiveRecord::Migration[#{rails_version_for_migration}]"
    end

    private

    def rails_version_for_migration
      rails_version.to_s.split('.')[0..1].join('.')
    end
  end
end
