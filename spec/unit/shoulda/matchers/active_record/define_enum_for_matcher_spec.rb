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

  if active_record_enum_supports_prefix_and_suffix?
    context 'qualified with #with_prefix' do
      context 'when the prefix is explicit' do
        context 'if the attribute was not defined with a prefix' do
          it 'rejects with an appropriate failure message' do
            record = build_record_with_array_values(
              model_name: 'Example',
              attribute_name: :attr,
              column_type: :integer,
              values: [:active, :archived],
            )

            assertion = lambda do
              expect(record).
                to define_enum_for(:attr).
                with_values([:active, :archived]).
                with_prefix(:foo)
            end

            message = format_message(<<-MESSAGE)
              Expected Example to define :attr as an enum, backed by an integer,
              using a prefix of :foo, with possible values ‹[:active,
              :archived]›. However, it was defined with either a different
              prefix or none at all.
            MESSAGE

            expect(&assertion).to fail_with_message(message)
          end
        end

        context 'if the attribute was defined with a different prefix' do
          it 'rejects with an appropriate failure message' do
            record = build_record_with_array_values(
              model_name: 'Example',
              attribute_name: :attr,
              column_type: :integer,
              values: [:active, :archived],
              prefix: :foo,
            )

            assertion = lambda do
              expect(record).
                to define_enum_for(:attr).
                with_values([:active, :archived]).
                with_prefix(:bar)
            end

            message = format_message(<<-MESSAGE)
              Expected Example to define :attr as an enum, backed by an integer,
              using a prefix of :bar, with possible values ‹[:active,
              :archived]›. However, it was defined with either a different
              prefix or none at all.
            MESSAGE

            expect(&assertion).to fail_with_message(message)
          end
        end

        context 'if the attribute was defined with the same prefix' do
          it 'accepts' do
            record = build_record_with_array_values(
              model_name: 'Example',
              attribute_name: :attr,
              values: [:active, :archived],
              prefix: :foo,
            )

            expect(record).
              to define_enum_for(:attr).
              with_values([:active, :archived]).
              with_prefix(:foo)
          end
        end
      end

      context 'when the prefix is implicit' do
        context 'if the attribute was not defined with a prefix' do
          it 'rejects with an appropriate failure message' do
            record = build_record_with_array_values(
              model_name: 'Example',
              attribute_name: :attr,
              column_type: :integer,
              values: [:active, :archived],
            )

            assertion = lambda do
              expect(record).
                to define_enum_for(:attr).
                with_values([:active, :archived]).
                with_prefix
            end

            message = format_message(<<-MESSAGE)
              Expected Example to define :attr as an enum, backed by an integer,
              using a prefix of :attr, with possible values ‹[:active,
              :archived]›. However, it was defined with either a different
              prefix or none at all.
            MESSAGE

            expect(&assertion).to fail_with_message(message)
          end
        end

        context 'if the attribute was defined with a prefix' do
          it 'accepts' do
            record = build_record_with_array_values(
              model_name: 'Example',
              attribute_name: :attr,
              values: [:active, :archived],
              prefix: true,
            )

            expect(record).
              to define_enum_for(:attr).
              with_values([:active, :archived]).
              with_prefix
          end
        end
      end
    end

    context 'qualified with #with_suffix' do
      context 'when the suffix is explicit' do
        context 'if the attribute was not defined with a suffix' do
          it 'rejects with an appropriate failure message' do
            record = build_record_with_array_values(
              model_name: 'Example',
              attribute_name: :attr,
              column_type: :integer,
              values: [:active, :archived],
            )

            assertion = lambda do
              expect(record).
                to define_enum_for(:attr).
                with_values([:active, :archived]).
                with_suffix(:foo)
            end

            message = format_message(<<-MESSAGE)
              Expected Example to define :attr as an enum, backed by an integer,
              using a suffix of :foo, with possible values ‹[:active,
              :archived]›. However, it was defined with either a different
              suffix or none at all.
            MESSAGE

            expect(&assertion).to fail_with_message(message)
          end
        end

        context 'if the attribute was defined with a different suffix' do
          it 'rejects with an appropriate failure message' do
            record = build_record_with_array_values(
              model_name: 'Example',
              attribute_name: :attr,
              column_type: :integer,
              values: [:active, :archived],
              suffix: :foo,
            )

            assertion = lambda do
              expect(record).
                to define_enum_for(:attr).
                with_values([:active, :archived]).
                with_suffix(:bar)
            end

            message = format_message(<<-MESSAGE)
              Expected Example to define :attr as an enum, backed by an integer,
              using a suffix of :bar, with possible values ‹[:active,
              :archived]›. However, it was defined with either a different
              suffix or none at all.
            MESSAGE

            expect(&assertion).to fail_with_message(message)
          end
        end

        context 'if the attribute was defined with the same suffix' do
          it 'accepts' do
            record = build_record_with_array_values(
              model_name: 'Example',
              attribute_name: :attr,
              values: [:active, :archived],
              suffix: :foo,
            )

            expect(record).
              to define_enum_for(:attr).
              with_values([:active, :archived]).
              with_suffix(:foo)
          end
        end
      end

      context 'when the suffix is implicit' do
        context 'if the attribute was not defined with a suffix' do
          it 'rejects with an appropriate failure message' do
            record = build_record_with_array_values(
              model_name: 'Example',
              attribute_name: :attr,
              column_type: :integer,
              values: [:active, :archived],
            )

            assertion = lambda do
              expect(record).
                to define_enum_for(:attr).
                with_values([:active, :archived]).
                with_suffix
            end

            message = format_message(<<-MESSAGE)
              Expected Example to define :attr as an enum, backed by an integer,
              using a suffix of :attr, with possible values ‹[:active,
              :archived]›. However, it was defined with either a different
              suffix or none at all.
            MESSAGE

            expect(&assertion).to fail_with_message(message)
          end
        end

        context 'if the attribute was defined with a suffix' do
          it 'accepts' do
            record = build_record_with_array_values(
              model_name: 'Example',
              attribute_name: :attr,
              values: [:active, :archived],
              suffix: true,
            )

            expect(record).
              to define_enum_for(:attr).
              with_values([:active, :archived]).
              with_suffix
          end
        end
      end
    end

    context 'qualified with both #with_prefix and #with_suffix' do
      context 'if the attribute was not defined with a different prefix' do
        it 'rejects with an appropriate failure message' do
          record = build_record_with_array_values(
            model_name: 'Example',
            attribute_name: :attr,
            column_type: :integer,
            values: [:active, :archived],
            prefix: :foo,
            suffix: :bar,
          )

          assertion = lambda do
            expect(record).
              to define_enum_for(:attr).
              with_values([:active, :archived]).
              with_prefix(:whatever).
              with_suffix(:bar)
          end

          message = format_message(<<-MESSAGE)
            Expected Example to define :attr as an enum, backed by an integer,
            using a prefix of :whatever and a suffix of :bar, with possible
            values ‹[:active, :archived]›. However, it was defined with either
            a different prefix, a different suffix, or neither one at all.
          MESSAGE

          expect(&assertion).to fail_with_message(message)
        end

        context 'if the attribute was defined with a different suffix' do
          it 'rejects with an appropriate failure message' do
            record = build_record_with_array_values(
              model_name: 'Example',
              attribute_name: :attr,
              column_type: :integer,
              values: [:active, :archived],
              prefix: :foo,
              suffix: :bar,
            )

            assertion = lambda do
              expect(record).
                to define_enum_for(:attr).
                with_values([:active, :archived]).
                with_prefix(:foo).
                with_suffix(:whatever)
            end

            message = format_message(<<-MESSAGE)
              Expected Example to define :attr as an enum, backed by an integer,
              using a prefix of :foo and a suffix of :whatever, with possible
              values ‹[:active, :archived]›. However, it was defined with
              either a different prefix, a different suffix, or neither one at
              all.
            MESSAGE

            expect(&assertion).to fail_with_message(message)
          end
        end

        context 'if the attribute was defined with the same prefix and suffix' do
          it 'accepts' do
            record = build_record_with_array_values(
              model_name: 'Example',
              attribute_name: :attr,
              values: [:active, :archived],
              prefix: :foo,
              suffix: :bar,
            )

            expect(record).
              to define_enum_for(:attr).
              with_values([:active, :archived]).
              with_prefix(:foo).
              with_suffix(:bar)
          end
        end
      end
    end
  end

  def build_record_with_array_values(
    model_name: 'Example',
    attribute_name: :attr,
    column_type: :integer,
    values: ['published', 'unpublished', 'draft'],
    prefix: false,
    suffix: false
  )
    build_record_with_enum_attribute(
      model_name: model_name,
      attribute_name: attribute_name,
      column_type: column_type,
      values: values,
      prefix: prefix,
      suffix: suffix,
    )
  end

  def build_record_with_hash_values(
    model_name: 'Example',
    attribute_name: :attr,
    values: { active: 0, archived: 1 },
    prefix: false,
    suffix: false
  )
    build_record_with_enum_attribute(
      model_name: model_name,
      attribute_name: attribute_name,
      column_type: :integer,
      values: values,
      prefix: prefix,
      suffix: suffix,
    )
  end

  def build_record_with_enum_attribute(
    model_name:,
    attribute_name:,
    column_type:,
    values:,
    prefix: false,
    suffix: false
  )
    model = define_model(
      model_name,
      attribute_name => { type: column_type },
    )

    if active_record_enum_supports_prefix_and_suffix?
      model.enum(attribute_name => values, _prefix: prefix, _suffix: suffix)
    else
      model.enum(attribute_name => values)
    end

    model.new
  end

  def build_record_with_non_enum_attribute(model_name:, attribute_name:)
    define_model(model_name, attribute_name => :integer).new
  end
end
