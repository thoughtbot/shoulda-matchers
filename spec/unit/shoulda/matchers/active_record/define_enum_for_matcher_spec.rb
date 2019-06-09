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
        Expected Example to define :attrs as an enum, but no such enum exists on
        Example.
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
        Expected Example to define :attr as an enum, but no such enum exists on
        Example.
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
          Expected Example to define :attr as an enum, but no such enum exists
          on Example.
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
          Expected Example to define :attr as an enum backed by an integer.
          However, :attr is a string column.
        MESSAGE

        assertion = lambda do
          expect(record).to define_enum_for(:attr)
        end

        expect(&assertion).to fail_with_message(message)
      end
    end

    context 'if the attribute is defined as an enum' do
      it 'matches' do
        record = build_record_with_array_values(attribute_name: :attr)

        expect { define_enum_for(:attr) }.
          to match_against(record).
          or_fail_with(<<-MESSAGE, wrap: true)
            Expected Example not to define :attr as an enum backed by an
            integer, but it did.
          MESSAGE
      end

      it 'has the right description' do
        matcher = define_enum_for(:attr)

        expect(matcher.description).to eq(<<~MESSAGE.strip)
          define :attr as an enum backed by an integer
        MESSAGE
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
            Expected Example to define :attr as an enum, but no such enum
            exists on Example.
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
              Expected Example to define :attr as an enum backed by an integer,
              mapping ‹"open"› to ‹0› and ‹"close"› to ‹1›. However, :attr
              actually maps ‹"published"› to ‹0›, ‹"unpublished"› to ‹1›, and
              ‹"draft"› to ‹2›.
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
          it 'matches' do
            record = build_record_with_array_values(
              attribute_name: :attr,
              values: ['published', 'unpublished', 'draft'],
            )

            matcher = lambda do
              define_enum_for(:attr).
                with_values(['published', 'unpublished', 'draft'])
            end

            expect(&matcher).
              to match_against(record).
              or_fail_with(<<-MESSAGE, wrap: true)
                Expected Example not to define :attr as an enum backed by an
                integer, mapping ‹"published"› to ‹0›, ‹"unpublished"› to ‹1›,
                and ‹"draft"› to ‹2›, but it did.
              MESSAGE
          end

          it 'has the right description' do
            matcher = define_enum_for(:attr).
              with_values(['published', 'unpublished', 'draft'])

            expect(matcher.description).to eq(<<~MESSAGE.strip)
              define :attr as an enum backed by an integer with values ‹["published", "unpublished", "draft"]›
            MESSAGE
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
            Expected Example to define :attr as an enum, but no such enum exists
            on Example.
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
              Expected Example to define :attr as an enum backed by an integer,
              mapping ‹"active"› to ‹5› and ‹"archived"› to ‹10›. However, :attr
              actually maps ‹"active"› to ‹0› and ‹"archived"› to ‹1›.
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
            it 'matches' do
              record = build_record_with_hash_values(
                attribute_name: :attr,
                values: { active: 0, archived: 1 },
              )

              matcher = lambda do
                define_enum_for(:attr).
                  with_values(active: 0, archived: 1)
              end

              expect(&matcher).
                to match_against(record).
                or_fail_with(<<-MESSAGE, wrap: true)
                  Expected Example not to define :attr as an enum backed by an
                  integer, mapping ‹"active"› to ‹0› and ‹"archived"› to ‹1›,
                  but it did.
                MESSAGE
            end

            it 'has the right description' do
              matcher = define_enum_for(:attr).
                with_values(active: 0, archived: 1)

              expect(matcher.description).to eq(<<~MESSAGE.strip)
                define :attr as an enum backed by an integer with values ‹{active: 0, archived: 1}›
              MESSAGE
            end
          end

          context 'when expected enum values are an array' do
            it 'matches' do
              record = build_record_with_hash_values(
                attribute_name: :attr,
                values: { active: 0, archived: 1 },
              )

              matcher = lambda do
                define_enum_for(:attr).
                  with_values(['active', 'archived'])
              end

              expect(&matcher).
                to match_against(record).
                or_fail_with(<<-MESSAGE, wrap: true)
                  Expected Example not to define :attr as an enum backed by an
                  integer, mapping ‹"active"› to ‹0› and ‹"archived"› to ‹1›,
                  but it did.
                MESSAGE
            end

            it 'has the right description' do
              matcher = define_enum_for(:attr).
                with_values(['active', 'archived'])

              expect(matcher.description).to eq(<<~MESSAGE.strip)
                define :attr as an enum backed by an integer with values ‹["active", "archived"]›
              MESSAGE
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
          Expected Example to define :attr as an enum backed by a string.
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
      it 'matches' do
        record = build_record_with_array_values(
          attribute_name: :attr,
          column_type: :string,
        )

        matcher = lambda do
          define_enum_for(:attr).backed_by_column_of_type(:string)
        end

        expect(&matcher).
          to match_against(record).
          or_fail_with(<<-MESSAGE, wrap: true)
            Expected Example not to define :attr as an enum backed by a string,
            but it did.
        MESSAGE
      end

      it 'has the right description' do
        matcher = define_enum_for(:attr).backed_by_column_of_type(:string)

        expect(matcher.description).to eq(<<~MESSAGE.strip)
          define :attr as an enum backed by a string
        MESSAGE
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
              Expected Example to define :attr as an enum backed by an integer,
              mapping ‹"active"› to ‹0› and ‹"archived"› to ‹1› and prefixing
              accessor methods with "foo_". :attr does map to these values, but
              the enum is configured with either a different prefix or no prefix
              at all (we can't tell which).
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
              Expected Example to define :attr as an enum backed by an integer,
              mapping ‹"active"› to ‹0› and ‹"archived"› to ‹1› and prefixing
              accessor methods with "bar_". :attr does map to these values, but
              the enum is configured with either a different prefix or no prefix
              at all (we can't tell which).
            MESSAGE

            expect(&assertion).to fail_with_message(message)
          end
        end

        context 'if the attribute was defined with the same prefix' do
          it 'matches' do
            record = build_record_with_array_values(
              model_name: 'Example',
              attribute_name: :attr,
              values: [:active, :archived],
              prefix: :foo,
            )

            matcher = lambda do
              define_enum_for(:attr).
                with_values([:active, :archived]).
                with_prefix(:foo)
            end

            expect(&matcher).
              to match_against(record).
              or_fail_with(<<-MESSAGE, wrap: true)
                Expected Example not to define :attr as an enum backed by an
                integer, mapping ‹"active"› to ‹0› and ‹"archived"› to ‹1› and
                prefixing accessor methods with "foo_", but it did.
            MESSAGE
          end

          it 'has the right description' do
            matcher = define_enum_for(:attr).
              with_values([:active, :archived]).
              with_prefix(:foo)

            expect(matcher.description).to eq(<<~MESSAGE.strip)
              define :attr as an enum backed by an integer with values ‹[:active, :archived]›, prefix: :foo
            MESSAGE
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
              Expected Example to define :attr as an enum backed by an integer,
              mapping ‹"active"› to ‹0› and ‹"archived"› to ‹1› and prefixing
              accessor methods with "attr_". :attr does map to these values, but
              the enum is configured with either a different prefix or no prefix
              at all (we can't tell which).
            MESSAGE

            expect(&assertion).to fail_with_message(message)
          end
        end

        context 'if the attribute was defined with a prefix' do
          it 'matches' do
            record = build_record_with_array_values(
              model_name: 'Example',
              attribute_name: :attr,
              values: [:active, :archived],
              prefix: true,
            )

            matcher = lambda do
              define_enum_for(:attr).
                with_values([:active, :archived]).
                with_prefix
            end

            expect(&matcher).
              to match_against(record).
              or_fail_with(<<-MESSAGE, wrap: true)
                Expected Example not to define :attr as an enum backed by an
                integer, mapping ‹"active"› to ‹0› and ‹"archived"› to ‹1› and
                prefixing accessor methods with "attr_", but it did.
              MESSAGE
          end

          it 'has the right description' do
            matcher = define_enum_for(:attr).
              with_values([:active, :archived]).
              with_prefix

            expect(matcher.description).to eq(<<~MESSAGE.strip)
              define :attr as an enum backed by an integer with values ‹[:active, :archived]›, prefix: true
            MESSAGE
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
              Expected Example to define :attr as an enum backed by an integer,
              mapping ‹"active"› to ‹0› and ‹"archived"› to ‹1› and suffixing
              accessor methods with "_foo". :attr does map to these values, but
              the enum is configured with either a different suffix or no suffix
              at all (we can't tell which).
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
              Expected Example to define :attr as an enum backed by an integer,
              mapping ‹"active"› to ‹0› and ‹"archived"› to ‹1› and suffixing
              accessor methods with "_bar". :attr does map to these values, but
              the enum is configured with either a different suffix or no suffix
              at all (we can't tell which).
            MESSAGE

            expect(&assertion).to fail_with_message(message)
          end
        end

        context 'if the attribute was defined with the same suffix' do
          it 'matches' do
            record = build_record_with_array_values(
              model_name: 'Example',
              attribute_name: :attr,
              values: [:active, :archived],
              suffix: :foo,
            )

            matcher = lambda do
              define_enum_for(:attr).
                with_values([:active, :archived]).
                with_suffix(:foo)
            end

            expect(&matcher).
              to match_against(record).
              or_fail_with(<<-MESSAGE, wrap: true)
                Expected Example not to define :attr as an enum backed by an
                integer, mapping ‹"active"› to ‹0› and ‹"archived"› to ‹1› and
                suffixing accessor methods with "_foo", but it did.
              MESSAGE
          end

          it 'has the right description' do
            matcher = define_enum_for(:attr).
              with_values([:active, :archived]).
              with_suffix(:foo)

            expect(matcher.description).to eq(<<~MESSAGE.strip)
              define :attr as an enum backed by an integer with values ‹[:active, :archived]›, suffix: :foo
            MESSAGE
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
              Expected Example to define :attr as an enum backed by an integer,
              mapping ‹"active"› to ‹0› and ‹"archived"› to ‹1› and suffixing
              accessor methods with "_attr". :attr does map to these values, but
              the enum is configured with either a different suffix or no suffix
              at all (we can't tell which).
            MESSAGE

            expect(&assertion).to fail_with_message(message)
          end
        end

        context 'if the attribute was defined with a suffix' do
          it 'matches' do
            record = build_record_with_array_values(
              model_name: 'Example',
              attribute_name: :attr,
              values: [:active, :archived],
              suffix: true,
            )

            matcher = lambda do
              define_enum_for(:attr).
                with_values([:active, :archived]).
                with_suffix
            end

            expect(&matcher).
              to match_against(record).
              or_fail_with(<<-MESSAGE, wrap: true)
                Expected Example not to define :attr as an enum backed by an
                integer, mapping ‹"active"› to ‹0› and ‹"archived"› to ‹1› and
                suffixing accessor methods with "_attr", but it did.
              MESSAGE
          end

          it 'has the right description' do
            matcher = define_enum_for(:attr).
              with_values([:active, :archived]).
              with_suffix

            expect(matcher.description).to eq(<<~MESSAGE.strip)
              define :attr as an enum backed by an integer with values ‹[:active, :archived]›, suffix: true
            MESSAGE
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
            Expected Example to define :attr as an enum backed by an integer,
            mapping ‹"active"› to ‹0› and ‹"archived"› to ‹1›, prefixing
            accessor methods with "whatever_", and suffixing accessor methods
            with "_bar". :attr does map to these values, but the enum is
            configured with either a different prefix or suffix, or no prefix or
            suffix at all (we can't tell which).
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
              Expected Example to define :attr as an enum backed by an integer,
              mapping ‹"active"› to ‹0› and ‹"archived"› to ‹1›, prefixing
              accessor methods with "foo_", and suffixing accessor methods with
              "_whatever". :attr does map to these values, but the enum is
              configured with either a different prefix or suffix, or no prefix
              or suffix at all (we can't tell which).
            MESSAGE

            expect(&assertion).to fail_with_message(message)
          end
        end

        context 'if the attribute was defined with the same prefix and suffix' do
          it 'matches' do
            record = build_record_with_array_values(
              model_name: 'Example',
              attribute_name: :attr,
              values: [:active, :archived],
              prefix: :foo,
              suffix: :bar,
            )

            matcher = lambda do
              define_enum_for(:attr).
                with_values([:active, :archived]).
                with_prefix(:foo).
                with_suffix(:bar)
            end

            expect(&matcher).
              to match_against(record).
              or_fail_with(<<-MESSAGE, wrap: true)
                Expected Example not to define :attr as an enum backed by an
                integer, mapping ‹"active"› to ‹0› and ‹"archived"› to ‹1›,
                prefixing accessor methods with "foo_", and suffixing accessor
                methods with "_bar", but it did.
              MESSAGE
          end

          it 'has the right description' do
            matcher = define_enum_for(:attr).
              with_values([:active, :archived]).
              with_prefix(:foo).
              with_suffix(:bar)

            expect(matcher.description).to eq(<<~MESSAGE.strip)
              define :attr as an enum backed by an integer with values ‹[:active, :archived]›, prefix: :foo, suffix: :bar
            MESSAGE
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
