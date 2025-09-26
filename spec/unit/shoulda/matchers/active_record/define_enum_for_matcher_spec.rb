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
        def self.statuses
        end
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

  context 'if the attribute is defined as an enum but is an alias' do
    it 'matches' do
      record = build_record_with_array_values(attribute_name: :attr, attribute_alias: :attr_alias)

      expect { define_enum_for(:attr_alias) }.
        to match_against(record).
        or_fail_with(<<-MESSAGE, wrap: true)
          Expected Example not to define :attr_alias as an enum backed by an
          integer, but it did.
        MESSAGE
    end
  end

  describe 'qualified with #with_default' do
    context 'if default are defined on the enum' do
      context 'but with_default is not used' do
        it 'matches' do
          record = build_record_with_array_values(attribute_name: :attr, default: 'published')

          expect(record).to define_enum_for(:attr).with_values(['published', 'unpublished', 'draft'])
        end
      end

      context 'with_default is used and default is the same' do
        it 'matches' do
          record = build_record_with_array_values(attribute_name: :attr, default: 'published')

          matcher = lambda do
            define_enum_for(:attr).
              with_values(['published', 'unpublished', 'draft']).
              with_default('published')
          end

          expect(&matcher).
            to match_against(record).
            or_fail_with(<<-MESSAGE, wrap: true)
              Expected Example not to define :attr as an enum backed by an
              integer, mapping ‹"published"› to ‹0›, ‹"unpublished"› to ‹1›,
              and ‹"draft"› to ‹2›, with a default value of ‹"published"›, but it did.
          MESSAGE
        end
      end

      context 'with_default is used but default is different' do
        it 'rejects with an appropriate failure message' do
          record = build_record_with_array_values(attribute_name: :attr, default: 'published')

          assertion = lambda do
            expect(record).
              to define_enum_for(:attr).
              with_values(['published', 'unpublished', 'draft']).
              with_default('unpublished')
          end

          message = format_message(<<-MESSAGE)
            Expected Example to define :attr as an enum backed by an integer,
            mapping ‹"published"› to ‹0›, ‹"unpublished"› to ‹1›, and ‹"draft"›
            to ‹2›, with a default value of ‹"unpublished"›. However, the default value
            is ‹"published"›.
          MESSAGE

          expect(&assertion).to fail_with_message(message)
        end
      end

      context 'when a Proc is used as the default value' do
        it 'rejects with an appropriate failure message' do
          record = build_record_with_array_values(attribute_name: :attr, default: 'draft')

          assertion = lambda do
            expect(record).
              to define_enum_for(:attr).
              with_values(['published', 'unpublished', 'draft']).
              with_default(-> { 'published' })
          end

          message = format_message(<<-MESSAGE)
            Expected Example to define :attr as an enum backed by an integer,
            mapping ‹"published"› to ‹0›, ‹"unpublished"› to ‹1›, and ‹"draft"›
            to ‹2›, with a default value of ‹"published"›. However, the default
            value is ‹"draft"›.
          MESSAGE

          expect(&assertion).to fail_with_message(message)
        end

        it 'matches when the default value is the same' do
          record = build_record_with_array_values(attribute_name: :attr, default: 'draft')

          matcher = lambda do
            define_enum_for(:attr).
              with_values(['published', 'unpublished', 'draft']).
              with_default(-> { 'draft' })
          end

          expect(&matcher).
            to match_against(record).
            or_fail_with(<<-MESSAGE, wrap: true)
              Expected Example not to define :attr as an enum backed by an
              integer, mapping ‹"published"› to ‹0›, ‹"unpublished"› to ‹1›,
              and ‹"draft"› to ‹2›, with a default value of ‹"draft"›, but it did.
          MESSAGE
        end
      end
    end

    context 'if default is not defined on the enum' do
      it 'rejects with an appropriate failure message' do
        record = build_record_with_array_values(attribute_name: :attr)

        assertion = lambda do
          expect(record).
            to define_enum_for(:attr).
            with_values(['published', 'unpublished', 'draft']).
            with_default('published')
        end

        message = format_message(<<-MESSAGE)
          Expected Example to define :attr as an enum backed by an integer,
          mapping ‹"published"› to ‹0›, ‹"unpublished"› to ‹1›, and ‹"draft"›
          to ‹2›, with a default value of ‹"published"›. However, no default
          value was set.
        MESSAGE

        expect(&assertion).to fail_with_message(message)
      end
    end
  end

  if rails_version >= 7.1
    describe 'qualified with #validating' do
      context 'enum values are an array' do
        context 'if enum is being validated' do
          context 'but validating qualifier is not used' do
            it 'matches' do
              record = build_record_with_array_values(attribute_name: :attr, default: 'published', validate: true)

              matcher = lambda do
                define_enum_for(:attr).with_values(['published', 'unpublished', 'draft'])
              end

              message = format_message(<<-MESSAGE)
                Expected Example not to define :attr as an enum backed by an integer,
                mapping ‹"published"› to ‹0›, ‹"unpublished"› to ‹1›, and ‹"draft"›
                to ‹2›, but it did.
              MESSAGE

              expect(&matcher).to match_against(record).or_fail_with(message)
            end
          end

          context 'and validating qualifier is used as false' do
            it 'rejects with an appropriate failure message' do
              record = build_record_with_array_values(attribute_name: :attr, default: 'published', validate: true)

              assertion = lambda do
                expect(record).
                  to define_enum_for(:attr).
                  with_values(['published', 'unpublished', 'draft']).
                  validating(false)
              end

              message = format_message(<<-MESSAGE)
                Expected Example to define :attr as an enum backed by an integer,
                mapping ‹"published"› to ‹0›, ‹"unpublished"› to ‹1›, and ‹"draft"›
                to ‹2›. However, :attr is being validated.
              MESSAGE

              expect(&assertion).to fail_with_message(message)
            end
          end

          context 'and validating qualifier is used' do
            it 'matches' do
              record = build_record_with_array_values(attribute_name: :attr, validate: true)

              matcher = lambda do
                define_enum_for(:attr).
                  with_values(['published', 'unpublished', 'draft']).
                  validating
              end

              message = format_message(<<-MESSAGE)
                Expected Example not to define :attr as an enum backed by an integer,
                mapping ‹"published"› to ‹0›, ‹"unpublished"› to ‹1›, and ‹"draft"›
                to ‹2›, and being validated not allowing nil values, but it did.
              MESSAGE

              expect(&matcher).to match_against(record).or_fail_with(message)
            end
          end

          context 'using allow_nil' do
            context 'when allowing nil on qualifier' do
              it 'matches' do
                record = build_record_with_array_values(attribute_name: :attr, validate: { allow_nil: true })

                matcher = lambda do
                  define_enum_for(:attr).
                    with_values(['published', 'unpublished', 'draft']).
                    validating(allowing_nil: true)
                end

                message = format_message(<<-MESSAGE)
                  Expected Example not to define :attr as an enum backed by an integer,
                  mapping ‹"published"› to ‹0›, ‹"unpublished"› to ‹1›, and ‹"draft"›
                  to ‹2›, and being validated allowing nil values, but it did.
                MESSAGE

                expect(&matcher).to match_against(record).or_fail_with(message)
              end
            end

            context 'when not allowing nil on qualifier' do
              it 'rejects with an appropriate failure message' do
                record = build_record_with_array_values(attribute_name: :attr, validate: { allow_nil: true })

                assertion = lambda do
                  expect(record).
                    to define_enum_for(:attr).
                    with_values(['published', 'unpublished', 'draft']).
                    validating
                end

                message = format_message(<<-MESSAGE)
                  Expected Example to define :attr as an enum backed by an integer,
                  mapping ‹"published"› to ‹0›, ‹"unpublished"› to ‹1›, and ‹"draft"›
                  to ‹2›, and being validated not allowing nil values. However, :attr is
                  allowing nil values.
                MESSAGE

                expect(&assertion).to fail_with_message(message)
              end
            end
          end
        end

        context 'when not allowing nil values' do
          it 'matches if qualifier does not allow' do
            record = build_record_with_array_values(attribute_name: :attr, validate: { allow_nil: false })

            matcher = lambda do
              define_enum_for(:attr).
                with_values(['published', 'unpublished', 'draft']).
                validating(allowing_nil: false)
            end

            message = format_message(<<-MESSAGE)
              Expected Example not to define :attr as an enum backed by an integer,
              mapping ‹"published"› to ‹0›, ‹"unpublished"› to ‹1›, and ‹"draft"›
              to ‹2›, and being validated not allowing nil values, but it did.
            MESSAGE

            expect(&matcher).to match_against(record).or_fail_with(message)
          end

          it 'rejects with an appropriate failure message if qualifier allows' do
            record = build_record_with_array_values(attribute_name: :attr, validate: { allow_nil: false })

            assertion = lambda do
              expect(record).
                to define_enum_for(:attr).
                with_values(['published', 'unpublished', 'draft']).
                validating(allowing_nil: true)
            end

            message = format_message(<<-MESSAGE)
              Expected Example to define :attr as an enum backed by an integer,
              mapping ‹"published"› to ‹0›, ‹"unpublished"› to ‹1›, and ‹"draft"›
              to ‹2›, and being validated allowing nil values. However, :attr is allowing
              nil values.
            MESSAGE

            expect(&assertion).to fail_with_message(message)
          end
        end

        context 'if enum is not being validated' do
          context 'but validating qualifier is used' do
            it 'rejects with an appropriate failure message' do
              record = build_record_with_array_values(attribute_name: :attr, default: 'published')

              assertion = lambda do
                expect(record).
                  to define_enum_for(:attr).
                  with_values(['published', 'unpublished', 'draft']).
                  validating
              end

              message = format_message(<<-MESSAGE)
                Expected Example to define :attr as an enum backed by an integer,
                mapping ‹"published"› to ‹0›, ‹"unpublished"› to ‹1›, and ‹"draft"›
                to ‹2›, and being validated not allowing nil values. However, :attr
                is not being validated.
              MESSAGE

              expect(&assertion).to fail_with_message(message)
            end
          end

          context 'and validating qualifier is used as false' do
            it 'matches' do
              record = build_record_with_array_values(attribute_name: :attr, default: 'published')

              matcher = lambda do
                define_enum_for(:attr).
                  with_values(['published', 'unpublished', 'draft']).
                  validating(false)
              end

              message = format_message(<<-MESSAGE)
                Expected Example not to define :attr as an enum backed by an integer,
                mapping ‹"published"› to ‹0›, ‹"unpublished"› to ‹1›, and ‹"draft"›
                to ‹2›, but it did.
              MESSAGE

              expect(&matcher).to match_against(record).or_fail_with(message)
            end
          end

          context 'and validating qualifier is not used' do
            it 'matches' do
              record = build_record_with_array_values(attribute_name: :attr, default: 'published')

              matcher = lambda do
                define_enum_for(:attr).with_values(['published', 'unpublished', 'draft'])
              end

              message = format_message(<<-MESSAGE)
                Expected Example not to define :attr as an enum backed by an integer,
                mapping ‹"published"› to ‹0›, ‹"unpublished"› to ‹1›, and ‹"draft"›
                to ‹2›, but it did.
              MESSAGE

              expect(&matcher).to match_against(record).or_fail_with(message)
            end
          end
        end
      end

      context 'enum values are a hash' do
        context 'if enum is being validated' do
          context 'but validating qualifier is not used' do
            it 'matches' do
              record = build_record_with_hash_values(attribute_name: :attr, default: 'active', validate: true)

              matcher = lambda do
                define_enum_for(:attr).with_values(active: 0, archived: 1)
              end

              message = format_message(<<-MESSAGE)
                Expected Example not to define :attr as an enum backed by an integer,
                mapping ‹"active"› to ‹0› and ‹"archived"› to ‹1›,
                but it did.
              MESSAGE

              expect(&matcher).to match_against(record).or_fail_with(message)
            end
          end

          context 'and validating qualifier is used as false' do
            it 'rejects with an appropriate failure message' do
              record = build_record_with_hash_values(attribute_name: :attr, default: 'active', validate: true)

              assertion = lambda do
                expect(record).
                  to define_enum_for(:attr).
                  with_values(active: 0, archived: 1).
                  validating(false)
              end

              message = format_message(<<-MESSAGE)
                Expected Example to define :attr as an enum backed by an integer,
                mapping ‹"active"› to ‹0› and ‹"archived"› to ‹1›.
                However, :attr is being validated.
              MESSAGE

              expect(&assertion).to fail_with_message(message)
            end
          end

          context 'and validating qualifier is used' do
            it 'matches' do
              record = build_record_with_hash_values(attribute_name: :attr, validate: true)

              matcher = lambda do
                define_enum_for(:attr).
                  with_values(active: 0, archived: 1).
                  validating
              end

              message = format_message(<<-MESSAGE)
                Expected Example not to define :attr as an enum backed by an integer,
                mapping ‹"active"› to ‹0› and ‹"archived"› to ‹1›, and being validated
                not allowing nil values, but it did.
              MESSAGE

              expect(&matcher).to match_against(record).or_fail_with(message)
            end
          end

          context 'using allow_nil' do
            context 'when allowing nil on qualifier' do
              it 'matches' do
                record = build_record_with_hash_values(attribute_name: :attr, validate: { allow_nil: true })

                matcher = lambda do
                  define_enum_for(:attr).
                    with_values(active: 0, archived: 1).
                    validating(allowing_nil: true)
                end

                message = format_message(<<-MESSAGE)
                  Expected Example not to define :attr as an enum backed by an integer,
                  mapping ‹"active"› to ‹0› and ‹"archived"› to ‹1›,
                  and being validated allowing nil values, but it did.
                MESSAGE

                expect(&matcher).to match_against(record).or_fail_with(message)
              end
            end

            context 'when not allowing nil on qualifier' do
              it 'rejects with an appropriate failure message' do
                record = build_record_with_hash_values(attribute_name: :attr, validate: { allow_nil: true })

                assertion = lambda do
                  expect(record).
                    to define_enum_for(:attr).
                    with_values(active: 0, archived: 1).
                    validating
                end

                message = format_message(<<-MESSAGE)
                  Expected Example to define :attr as an enum backed by an integer,
                  mapping ‹"active"› to ‹0› and ‹"archived"› to ‹1›,
                  and being validated not allowing nil values. However, :attr is
                  allowing nil values.
                MESSAGE

                expect(&assertion).to fail_with_message(message)
              end
            end
          end
        end

        context 'when not allowing nil values' do
          it 'matches if qualifier does not allow' do
            record = build_record_with_hash_values(attribute_name: :attr, validate: { allow_nil: false })

            matcher = lambda do
              define_enum_for(:attr).
                with_values(active: 0, archived: 1).
                validating(allowing_nil: false)
            end

            message = format_message(<<-MESSAGE)
              Expected Example not to define :attr as an enum backed by an integer,
              mapping ‹"active"› to ‹0› and ‹"archived"› to ‹1›,
              and being validated not allowing nil values, but it did.
            MESSAGE

            expect(&matcher).to match_against(record).or_fail_with(message)
          end

          it 'rejects with an appropriate failure message if qualifier allows' do
            record = build_record_with_hash_values(attribute_name: :attr, validate: { allow_nil: false })

            assertion = lambda do
              expect(record).
                to define_enum_for(:attr).
                with_values(active: 0, archived: 1).
                validating(allowing_nil: true)
            end

            message = format_message(<<-MESSAGE)
              Expected Example to define :attr as an enum backed by an integer,
              mapping ‹"active"› to ‹0› and ‹"archived"› to ‹1›,
              and being validated allowing nil values. However, :attr is allowing
              nil values.
            MESSAGE

            expect(&assertion).to fail_with_message(message)
          end
        end

        context 'if enum is not being validated' do
          context 'but validating qualifier is used' do
            it 'rejects with an appropriate failure message' do
              record = build_record_with_hash_values(attribute_name: :attr, default: 'active')

              assertion = lambda do
                expect(record).
                  to define_enum_for(:attr).
                  with_values(active: 0, archived: 1).
                  validating
              end

              message = format_message(<<-MESSAGE)
                Expected Example to define :attr as an enum backed by an integer,
                mapping ‹"active"› to ‹0› and ‹"archived"› to ‹1›,
                and being validated not allowing nil values. However, :attr
                is not being validated.
              MESSAGE

              expect(&assertion).to fail_with_message(message)
            end
          end

          context 'and validating qualifier is used as false' do
            it 'matches' do
              record = build_record_with_hash_values(attribute_name: :attr, default: 'active')

              matcher = lambda do
                define_enum_for(:attr).
                  with_values(active: 0, archived: 1).
                  validating(false)
              end

              message = format_message(<<-MESSAGE)
                Expected Example not to define :attr as an enum backed by an integer,
                mapping ‹"active"› to ‹0› and ‹"archived"› to ‹1›,
                but it did.
              MESSAGE

              expect(&matcher).to match_against(record).or_fail_with(message)
            end
          end

          context 'and validating qualifier is not used' do
            it 'matches' do
              record = build_record_with_hash_values(attribute_name: :attr, default: 'active')

              matcher = lambda do
                define_enum_for(:attr).with_values(active: 0, archived: 1)
              end

              message = format_message(<<-MESSAGE)
                Expected Example not to define :attr as an enum backed by an integer,
                mapping ‹"active"› to ‹0› and ‹"archived"› to ‹1›,
                but it did.
              MESSAGE

              expect(&matcher).to match_against(record).or_fail_with(message)
            end
          end
        end
      end
    end

    describe 'qualified with #without_instance_methods' do
      context 'if instance methods are set to false on the enum but without_instance_methods is not used' do
        it 'rejects with failure message' do
          record = build_record_with_array_values(
            attribute_name: :attr,
            instance_methods: false,
          )

          matcher = lambda do
            expect(record).
              to define_enum_for(:attr).
              with_values(['published', 'unpublished', 'draft'])
          end

          message = format_message(<<-MESSAGE)
          Expected Example to define :attr as an enum backed by an integer,
          mapping ‹"published"› to ‹0›, ‹"unpublished"› to ‹1›, and ‹"draft"› to
          ‹2›. :attr does map to these values, but the enum is configured with no
          instance methods.
          MESSAGE

          expect(&matcher).to fail_with_message(message)
        end
      end

      context 'if instance methods are set to false on the enum' do
        it 'matches' do
          record = build_record_with_array_values(
            attribute_name: :attr,
            instance_methods: false,
          )

          matcher = lambda do
            define_enum_for(:attr).
              with_values(['published', 'unpublished', 'draft']).
              without_instance_methods
          end

          expect(&matcher).
            to match_against(record).
            or_fail_with(<<-MESSAGE)
            Expected Example not to define :attr as an enum backed by an integer,
            mapping ‹"published"› to ‹0›, ‹"unpublished"› to ‹1›, and ‹"draft"› to
            ‹2›, but it did.
          MESSAGE
        end
      end

      context 'if instance methods are not set to false on the enum' do
        it 'rejects with failure message' do
          record = build_record_with_array_values(attribute_name: :attr)

          matcher = lambda do
            expect(record).
              to define_enum_for(:attr).
              with_values(['published', 'unpublished', 'draft']).
              without_instance_methods
          end

          message = format_message(<<-MESSAGE)
          Expected Example to define :attr as an enum backed by an integer,
          mapping ‹"published"› to ‹0›, ‹"unpublished"› to ‹1›, and ‹"draft"› to
          ‹2›. :attr does map to these values with instance methods, but expected
          no instance methods.
          MESSAGE

          expect(&matcher).to fail_with_message(message)
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
    suffix: false,
    attribute_alias: nil,
    scopes: true,
    default: nil,
    validate: false,
    instance_methods: true
  )
    build_record_with_enum_attribute(
      model_name: model_name,
      attribute_name: attribute_name,
      column_type: column_type,
      values: values,
      prefix: prefix,
      suffix: suffix,
      attribute_alias: attribute_alias,
      scopes: scopes,
      default: default,
      validate: validate,
      instance_methods: instance_methods,
    )
  end

  def build_record_with_hash_values(
    model_name: 'Example',
    attribute_name: :attr,
    values: { active: 0, archived: 1 },
    prefix: false,
    suffix: false,
    scopes: true,
    default: nil,
    validate: false
  )
    build_record_with_enum_attribute(
      model_name: model_name,
      attribute_name: attribute_name,
      column_type: :integer,
      values: values,
      prefix: prefix,
      suffix: suffix,
      scopes: scopes,
      attribute_alias: nil,
      default: default,
      validate: validate,
    )
  end

  def build_record_with_enum_attribute(
    model_name:,
    attribute_name:,
    column_type:,
    values:,
    attribute_alias:,
    scopes: true,
    prefix: false,
    suffix: false,
    default: nil,
    validate: false,
    instance_methods: true
  )
    enum_name = attribute_alias || attribute_name
    model = define_model(
      model_name,
      attribute_name => { type: column_type },
    ) do
      alias_attribute attribute_alias, attribute_name
    end

    params = {
      enum_name => values,
      _prefix: prefix,
      _suffix: suffix,
      _default: default,
    }

    if rails_version >= 7.0
      model.enum(enum_name, values, prefix: prefix, suffix: suffix, validate: validate, default: default, instance_methods: instance_methods)
    else
      params.merge!(_scopes: scopes)
      model.enum(params)
    end

    model.new
  end

  def build_record_with_non_enum_attribute(model_name:, attribute_name:)
    define_model(model_name, attribute_name => :integer).new
  end
end
