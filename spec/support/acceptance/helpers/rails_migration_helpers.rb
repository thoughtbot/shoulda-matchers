require_relative 'gem_helpers'

module AcceptanceTests
  module RailsMigrationHelpers
    include RailsVersionHelpers

    def migration_class_name
      if rails_version >= 5
        "ActiveRecord::Migration[#{rails_version_for_migration}]"
      else
        'ActiveRecord::Migration'
      end
    end

    private

    def rails_version_for_migration
      rails_version.to_s.split('.')[0..1].join('.')
    end
  end
end
