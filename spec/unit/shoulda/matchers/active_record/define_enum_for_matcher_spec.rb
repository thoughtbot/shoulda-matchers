require "unit_spec_helper"

describe Shoulda::Matchers::ActiveRecord::DefineEnumForMatcher, type: :model do
  if active_record_supports_enum?
    context 'if the attribute is given in plural form accidentally' do
      it 'rejects' do
        record = record_with_array_values
        plural_enum_attribute = enum_attribute.to_s.pluralize
        message = "Expected #{record.class} to define :#{plural_enum_attribute} as an enum and store the value in a column with an integer type"

        assertion = lambda do
          expect(record).to define_enum_for(plural_enum_attribute)
        end

        expect(&assertion).to fail_with_message(message)
      end
    end

    context 'if a method to hold enum values exists on the model but was not created via the enum macro' do
      it 'rejects' do
        model = define_model :example do
          def self.statuses; end
        end

        message = "Expected #{model} to define :statuses as an enum and store the value in a column with an integer type"

        assertion = lambda do
          expect(model.new).to define_enum_for(:statuses)
        end

        expect(&assertion).to fail_with_message(message)
      end
    end

    describe "with only the attribute name specified" do
      it "accepts a record where the attribute is defined as an enum" do
        expect(record_with_array_values).to define_enum_for(enum_attribute)
      end

      it "rejects a record where the attribute is not defined as an enum" do
        message = "Expected #{record_with_array_values.class} to define :#{non_enum_attribute} as an enum and store the value in a column with an integer type"

        assertion = lambda do
          expect(record_with_array_values).
            to define_enum_for(non_enum_attribute)
        end

        expect(&assertion).to fail_with_message(message)
      end

      it "rejects a record where the attribute is not defined as an enum with should not" do
        message = "Did not expect #{record_with_array_values.class} to define :#{enum_attribute} as an enum and store the value in a column with an integer type"

        assertion = lambda do
          expect(record_with_array_values).
            not_to define_enum_for(enum_attribute)
        end

        expect(&assertion).to fail_with_message(message)
      end

      context 'if the column storing the attribute is not an integer type' do
        it 'rejects' do
          record = record_with_array_values(column_type: :string)
          message = "Expected #{record.class} to define :statuses as an enum and store the value in a column with an integer type"

          assertion = lambda do
            expect(record).to define_enum_for(:statuses)
          end

          expect(&assertion).to fail_with_message(message)
        end
      end
    end

    describe "with both attribute name and enum values specified" do
      context "when the actual enum values are an array" do
        it "accepts a record where the attribute is defined as an enum and the enum values match" do
          expect(record_with_array_values).to define_enum_for(enum_attribute).
            with(["published", "unpublished", "draft"])
        end

        it "accepts a record where the attribute is not defined as an enum" do
          message = %{Expected #{record_with_array_values.class} to define :#{non_enum_attribute} as an enum with ["open", "close"] and store the value in a column with an integer type}

          assertion = lambda do
            expect(record_with_array_values).
              to define_enum_for(non_enum_attribute).with(['open', 'close'])
          end

          expect(&assertion).to fail_with_message(message)
        end

        it "accepts a record where the attribute is defined as an enum but the enum values do not match" do
          message = %{Expected #{record_with_array_values.class} to define :#{enum_attribute} as an enum with ["open", "close"] and store the value in a column with an integer type}

          assertion = lambda do
            expect(record_with_array_values).
              to define_enum_for(enum_attribute).
              with(["open", "close"])
          end

          expect(&assertion).to fail_with_message(message)
        end
      end

      context "when the actual enum values are a hash" do
        it "accepts a record where the attribute is defined as an enum and the enum values match" do
          expect(record_with_hash_values).to define_enum_for(enum_attribute).with(active: 0, archived: 1)
        end

        it "accepts a record where the enum values match when expected enum values are given as an array" do
          expect(record_with_hash_values).to define_enum_for(enum_attribute).with(["active", "archived"])
        end

        it "accepts a record where the attribute is defined as an enum but the enum values do not match" do
          message = %{Expected #{record_with_hash_values.class} to define :#{enum_attribute} as an enum with {:active=>5, :archived=>10} and store the value in a column with an integer type}

          assertion = lambda do
            expect(record_with_hash_values).
              to define_enum_for(enum_attribute).
              with(active: 5, archived: 10)
          end

          expect(&assertion).to fail_with_message(message)
        end

        it "rejects a record where the attribute is not defined as an enum" do
          message = %{Expected #{record_with_hash_values.class} to define :record_with_hash_values as an enum with {:active=>5, :archived=>10} and store the value in a column with an integer type}

          assertion = lambda do
            expect(record_with_hash_values).
              to define_enum_for(:record_with_hash_values).
              with(active: 5, archived: 10)
          end

          expect(&assertion).to fail_with_message(message)
        end
      end
    end

    def enum_attribute
      :status
    end

    def non_enum_attribute
      :condition
    end

    def record_with_array_values(column_type: :integer)
      model = define_model(
        :record_with_array_values,
        enum_attribute => { type: column_type },
      )
      model.enum(enum_attribute => ['published', 'unpublished', 'draft'])
      model.new
    end

    def record_with_hash_values
      model = define_model(
        :record_with_hash_values,
        enum_attribute => { type: :integer },
      )
      model.enum(enum_attribute => { active: 0, archived: 1 })
      model.new
    end
  end
end
