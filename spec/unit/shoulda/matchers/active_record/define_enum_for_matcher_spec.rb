require "unit_spec_helper"

describe Shoulda::Matchers::ActiveRecord::DefineEnumForMatcher, type: :model do
  if active_record_supports_enum?
    it "rejects a record when checking for enum's plural attribute name" do
      message = "Expected #{record_with_array_values.class} to define :#{enum_attribute.to_s.pluralize} as an enum"

      expect do
        expect(record_with_array_values).to define_enum_for(enum_attribute.to_s.pluralize)
      end.to fail_with_message(message)
    end

    describe "with only the attribute name specified" do
      it "accepts a record where the attribute is defined as an enum" do
        expect(record_with_array_values).to define_enum_for(enum_attribute)
      end

      it "rejects a record where the attribute is not defined as an enum" do
        message = "Expected #{record_with_array_values.class} to define :#{non_enum_attribute} as an enum"

        expect do
          expect(record_with_array_values).to define_enum_for(non_enum_attribute)
        end.to fail_with_message(message)
      end

      it "rejects a record where the attribute is not defined as an enum with should not" do
        message = "Did not expect #{record_with_array_values.class} to define :#{enum_attribute} as an enum"

        expect do
          expect(record_with_array_values).to_not define_enum_for(enum_attribute)
        end.to fail_with_message(message)
      end
    end

    describe "with both attribute name and enum values specified" do
      context "when the actual enum values are an array" do
        it "accepts a record where the attribute is defined as an enum and the enum values match" do
          expect(record_with_array_values).to define_enum_for(enum_attribute).
            with(["published", "unpublished", "draft"])
        end

        it "accepts a record where the attribute is not defined as an enum" do
          message = %{Expected #{record_with_array_values.class} to define :#{non_enum_attribute} as an enum with ["open", "close"]}

          expect do
            expect(record_with_array_values).to define_enum_for(non_enum_attribute).with(["open", "close"])
          end.to fail_with_message(message)
        end

        it "accepts a record where the attribute is defined as an enum but the enum values do not match" do
          message = %{Expected #{record_with_array_values.class} to define :#{enum_attribute} as an enum with ["open", "close"]}

          expect do
            expect(record_with_array_values).to define_enum_for(enum_attribute).with(["open", "close"])
          end.to fail_with_message(message)
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
          message = %{Expected #{record_with_hash_values.class} to define :#{enum_attribute} as an enum with {:active=>5, :archived=>10}}

          expect do
            expect(record_with_hash_values).to define_enum_for(enum_attribute).with(active: 5, archived: 10)
          end.to fail_with_message(message)
        end

        it "rejects a record where the attribute is not defined as an enum" do
          message = %{Expected #{record_with_hash_values.class} to define :record_with_hash_values as an enum with {:active=>5, :archived=>10}}

          expect do
            expect(record_with_hash_values)
              .to define_enum_for(:record_with_hash_values).with(active: 5, archived: 10)
          end.to fail_with_message(message)
        end
      end
    end

    def enum_attribute
      :status
    end

    def non_enum_attribute
      :condition
    end

    def record_with_array_values
      _enum_attribute = enum_attribute
      define_model :record_with_array_values do
        enum(_enum_attribute => %w(published unpublished draft))
      end.new
    end

    def record_with_hash_values
      _enum_attribute = enum_attribute
      define_model :record_with_hash_values do
        enum(_enum_attribute => { active: 0, archived: 1 })
      end.new
    end
  end
end
