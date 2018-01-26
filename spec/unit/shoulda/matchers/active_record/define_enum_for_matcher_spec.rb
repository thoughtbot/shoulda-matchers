require 'unit_spec_helper'

describe Shoulda::Matchers::ActiveRecord::DefineEnumForMatcher, type: :model do
  context 'if the attribute is given in plural form accidentally' do
    it 'rejects with an appropriate failure message' do
      record = build_record_with_array_values(
        model_name: 'Example',
        attribute_name: :attr,
        column_type: :integer,
      )
      message = format_message(<<-MESSAGE)
        Expected Example to define :attrs as an enum, backed by an integer.
        However, no such enum exists in Example.
      MESSAGE

      assertion = lambda do
        expect(record).to define_enum_for(:attrs)
      end

      expect(&assertion).to fail_with_message(message)
    end
  end

  context 'if a method to hold enum values exists on the model but was not created via the enum macro' do
    it 'rejects with an appropriate failure message' do
      model = define_model 'Example' do
        def self.statuses; end
      end

      message = format_message(<<-MESSAGE)
        Expected Example to define :attr as an enum, backed by an integer.
        However, no such enum exists in Example.
      MESSAGE

      assertion = lambda do
        expect(model.new).to define_enum_for(:attr)
      end

      expect(&assertion).to fail_with_message(message)
    end
  end

  describe 'with only the attribute name specified' do
    context 'if the attribute is not defined as an enum' do
      it 'rejects with an appropriate failure message' do
        record = build_record_with_non_enum_attribute(
          model_name: 'Example',
          attribute_name: :attr,
        )
        message = format_message(<<-MESSAGE)
          Expected Example to define :attr as an enum, backed by an integer.
          However, no such enum exists in Example.
        MESSAGE

        assertion = lambda do
          expect(record).to define_enum_for(:attr)
        end

        expect(&assertion).to fail_with_message(message)
      end
    end

    context 'if the column storing the attribute is not an integer type' do
      it 'rejects with an appropriate failure message' do
        record = build_record_with_array_values(
          model_name: 'Example',
          attribute_name: :attr,
          column_type: :string,
        )
        message = format_message(<<-MESSAGE)
          Expected Example to define :attr as an enum, backed by an integer.
          However, :attr is a string column.
        MESSAGE

        assertion = lambda do
          expect(record).to define_enum_for(:attr)
        end

        expect(&assertion).to fail_with_message(message)
      end
    end

    context 'if the attribute is defined as an enum' do
      it 'accepts' do
        record = build_record_with_array_values(attribute_name: :attr)

        expect(record).to define_enum_for(:attr)
      end

      context 'and the matcher is negated' do
        it 'rejects with an appropriate failure message' do
          record = build_record_with_array_values(
            model_name: 'Example',
            attribute_name: :attr,
            column_type: :integer,
          )
          message = format_message(<<-MESSAGE)
            Expected Example not to define :attr as an enum, backed by an integer,
            but it did.
          MESSAGE

          assertion = lambda do
            expect(record).not_to define_enum_for(:attr)
          end

          expect(&assertion).to fail_with_message(message)
        end
      end
    end
  end

  describe 'with both attribute name and enum values specified' do
    context 'when the actual enum values are an array' do
      context 'if the attribute is not defined as an enum' do
        it 'rejects with an appropriate failure message' do
          record = build_record_with_non_enum_attribute(
            model_name: 'Example',
            attribute_name: :attr,
          )
          message = format_message(<<-MESSAGE)
            Expected Example to define :attr as an enum, backed by an integer,
            with possible values ‹["open", "close"]›. However, no such enum
            exists in Example.
          MESSAGE

          assertion = lambda do
            expect(record).
              to define_enum_for(:attr).
              with_values(['open', 'close'])
          end

          expect(&assertion).to fail_with_message(message)
        end
      end

      context 'if the attribute is defined as an enum' do
        context 'but the enum values do not match' do
          it 'rejects with an appropriate failure message' do
            record = build_record_with_array_values(
              model_name: 'Example',
              attribute_name: :attr,
              values: ['published', 'unpublished', 'draft'],
            )
            message = format_message(<<-MESSAGE)
              Expected Example to define :attr as an enum, backed by an integer,
              with possible values ‹["open", "close"]›. However, the actual
              enum values for :attr are ‹["published", "unpublished", "draft"]›.
            MESSAGE

            assertion = lambda do
              expect(record).
                to define_enum_for(:attr).
                with_values(['open', 'close'])
            end

            expect(&assertion).to fail_with_message(message)
          end
        end

        context 'and the enum values match' do
          it 'accepts' do
            record = build_record_with_array_values(
              attribute_name: :attr,
              values: ['published', 'unpublished', 'draft'],
            )

            expect(record).to define_enum_for(:attr).
              with_values(['published', 'unpublished', 'draft'])
          end
        end
      end
    end

    context 'when the actual enum values are a hash' do
      context 'if the attribute is not defined as an enum' do
        it 'rejects with an appropriate failure message' do
          record = build_record_with_non_enum_attribute(
            model_name: 'Example',
            attribute_name: :attr,
          )
          message = format_message(<<-MESSAGE)
            Expected Example to define :attr as an enum, backed by an integer,
            with possible values ‹{active: 5, archived: 10}›. However, no such
            enum exists in Example.
          MESSAGE

          assertion = lambda do
            expect(record).
              to define_enum_for(:attr).
              with_values(active: 5, archived: 10)
          end

          expect(&assertion).to fail_with_message(message)
        end
      end

      context 'if the attribute is defined as an enum' do
        context 'but the enum values do not match' do
          it 'rejects with an appropriate failure message' do
            record = build_record_with_hash_values(
              model_name: 'Example',
              attribute_name: :attr,
              values: { active: 0, archived: 1 },
            )
            message = format_message(<<-MESSAGE)
              Expected Example to define :attr as an enum, backed by an integer,
              with possible values ‹{active: 5, archived: 10}›. However, the
              actual enum values for :attr are ‹{active: 0, archived: 1}›.
            MESSAGE

            assertion = lambda do
              expect(record).
                to define_enum_for(:attr).
                with_values(active: 5, archived: 10)
            end

            expect(&assertion).to fail_with_message(message)
          end
        end

        context 'and the enum values match' do
          context 'when expected enum values are a hash' do
            it 'accepts' do
              record = build_record_with_hash_values(
                attribute_name: :attr,
                values: { active: 0, archived: 1 },
              )

              expect(record).
                to define_enum_for(:attr).
                with_values(active: 0, archived: 1)
            end
          end

          context 'when expected enum values are an array' do
            it 'accepts' do
              record = build_record_with_hash_values(
                attribute_name: :attr,
                values: { active: 0, archived: 1 },
              )

              expect(record).
                to define_enum_for(:attr).
                with_values(['active', 'archived'])
            end
          end
        end
      end
    end
  end

  context 'with values specified using #with' do
    it 'produces a warning' do
      record = build_record_with_array_values(
        attribute_name: :attr,
        values: [:foo, :bar],
      )

      assertion = lambda do
        expect(record).to define_enum_for(:attr).with([:foo, :bar])
      end

      expect(&assertion).to deprecate(
        'The `with` qualifier on `define_enum_for`',
        '`with_values`',
      )
    end
  end

  describe 'with the backing column specified to be of some type' do
    context 'if the column storing the attribute is of a different type' do
      it 'rejects with an appropriate failure message' do
        record = build_record_with_array_values(
          model_name: 'Example',
          attribute_name: :attr,
          column_type: :integer,
        )
        message = format_message(<<-MESSAGE)
          Expected Example to define :attr as an enum, backed by a string.
          However, :attr is an integer column.
        MESSAGE

        assertion = lambda do
          expect(record).
            to define_enum_for(:attr).
            backed_by_column_of_type(:string)
        end

        expect(&assertion).to fail_with_message(message)
      end
    end

    context 'if the column storing the attribute is of the same type' do
      it 'accepts' do
        record = build_record_with_array_values(
          attribute_name: :attr,
          column_type: :string,
        )

        expect(record).
          to define_enum_for(:attr).
          backed_by_column_of_type(:string)
      end
    end
  end

  def build_record_with_array_values(
    model_name: 'Example',
    attribute_name: :attr,
    column_type: :integer,
    values: ['published', 'unpublished', 'draft']
  )
    build_record_with_enum_attribute(
      model_name: model_name,
      attribute_name: attribute_name,
      column_type: column_type,
      values: values,
    )
  end

  def build_record_with_hash_values(
    model_name: 'Example',
    attribute_name: :attr,
    values: { active: 0, archived: 1 }
  )
    build_record_with_enum_attribute(
      model_name: model_name,
      attribute_name: attribute_name,
      column_type: :integer,
      values: values,
    )
  end

  def build_record_with_enum_attribute(
    model_name:,
    attribute_name:,
    column_type:,
    values:
  )
    model = define_model(
      model_name,
      attribute_name => column_type,
    )
    model.enum(attribute_name => values)
    model.new
  end

  def build_record_with_non_enum_attribute(model_name:, attribute_name:)
    define_model(model_name, attribute_name => :integer).new
  end
end
