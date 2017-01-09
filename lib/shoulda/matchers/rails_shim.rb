module Shoulda
  module Matchers
    # @private
    class RailsShim
      class << self
        def action_pack_gte_4_1?
          Gem::Requirement.new('>= 4.1').satisfied_by?(action_pack_version)
        end

        def action_pack_gte_5?
          Gem::Requirement.new('>= 5').satisfied_by?(action_pack_version)
        end

        def action_pack_version
          Gem::Version.new(::ActionPack::VERSION::STRING)
        end

        def active_record_major_version
          ::ActiveRecord::VERSION::MAJOR
        end

        def generate_validation_message(
          record,
          attribute,
          type,
          model_name,
          options
        )
          if record && record.errors.respond_to?(:generate_message)
            record.errors.generate_message(attribute.to_sym, type, options)
          else
            simply_generate_validation_message(
              attribute,
              type,
              model_name,
              options,
            )
          end
        rescue RangeError
          simply_generate_validation_message(
            attribute,
            type,
            model_name,
            options,
          )
        end

        def make_controller_request(context, verb, action, request_params)
          params =
            if action_pack_gte_5?
              { params: request_params }
            else
              request_params
            end

          context.__send__(verb, action, params)
        end

        def serialized_attributes_for(model)
          if defined?(::ActiveRecord::Type::Serialized)
            # Rails 5+
            serialized_columns = model.columns.select do |column|
              model.type_for_attribute(column.name).is_a?(
                ::ActiveRecord::Type::Serialized,
              )
            end

            serialized_columns.inject({}) do |hash, column|
              hash[column.name.to_s] = model.type_for_attribute(column.name).coder
              hash
            end
          else
            model.serialized_attributes
          end
        end

        def type_cast_default_for(model, column)
          if model.respond_to?(:column_defaults)
            # Rails 4.2
            model.column_defaults[column.name]
          else
            column.default
          end
        end

        def tables_and_views(connection)
          if active_record_major_version >= 5
            connection.data_sources
          else
            connection.tables
          end
        end

        def verb_for_update
          if action_pack_gte_4_1?
            :patch
          else
            :put
          end
        end

        private

        def simply_generate_validation_message(
          attribute,
          type,
          model_name,
          options
        )
          default_translation_keys = [
            :"activerecord.errors.models.#{model_name}.#{type}",
            :"activerecord.errors.messages.#{type}",
            :"errors.attributes.#{attribute}.#{type}",
            :"errors.messages.#{type}",
          ]
          primary_translation_key = [
            :activerecord,
            :errors,
            :models,
            model_name,
            :attributes,
            attribute,
            type,
          ]
          translate_options =
            { default: default_translation_keys }.merge(options)
          I18n.translate(primary_translation_key, translate_options)
        end
      end
    end
  end
end
