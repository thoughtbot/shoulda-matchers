module Shoulda
  module Matchers
    module ActiveRecord
      module AssociationMatchers
        class ModelReflectionMacro

          def initialize(reflection, macro_name = nil)
            @reflection, @macro_name = reflection, macro_name
          end

          def join_table
            join_table =
              if has_and_belongs_to_name_table_name
                has_and_belongs_to_name_table_name
              elsif reflection.respond_to?(:join_table)
                reflection.join_table
              else
                reflection.options[:join_table]
              end

            join_table.to_s
          end

          private
            attr_reader :reflection, :macro_name

            def has_and_belongs_to_name_table_name
              return false if reflection.options[:through].nil?
              reflection.active_record.reflect_on_all_associations.detect { |r| r.plural_name.to_sym == reflection.options[:through] }
              .options[:class].table_name
            end
        end
      end
    end
  end
end
