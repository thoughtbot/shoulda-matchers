require 'unit_spec_helper'

describe Shoulda::Matchers::ActiveModel::ValidateLengthOfMatcher, type: :model do
  context 'an attribute with a non-zero minimum length validation' do
    it 'accepts ensuring the correct minimum length' do
      expect(validating_length(minimum: 4)).
        to validate_length_of(:attr).is_at_least(4)
    end

    it 'rejects ensuring a lower minimum length with any message' do
      expect(validating_length(minimum: 4)).
        not_to validate_length_of(:attr).is_at_least(3).with_short_message(/.*/)
    end

    it 'rejects ensuring a higher minimum length with any message' do
      expect(validating_length(minimum: 4)).
        not_to validate_length_of(:attr).is_at_least(5).with_short_message(/.*/)
    end

    it 'does not override the default message with a blank' do
      expect(validating_length(minimum: 4)).
        to validate_length_of(:attr).is_at_least(4).with_short_message(nil)
    end

    context 'when the writer method for the attribute changes incoming values' do
      context 'and the matcher knows nothing of this' do
        it 'raises a CouldNotSetAttributeError' do
          record = build_record_validating_length(
            attribute_name: :name,
            convert_attribute_with: :upcase,
            minimum: 4
          )

          assertion = lambda do
            expect(record).to validate_length_of(:name).is_at_least(4)
          end

          expect(&assertion).to raise_error(
            Shoulda::Matchers::ActiveModel::AllowValueMatcher::CouldNotSetAttributeError
          )
        end
      end

      context 'and the matcher knows how given values get changed' do
        it 'accepts (and not raise an error)' do
          record = build_record_validating_length(
            attribute_name: :name,
            convert_attribute_with: :upcase,
            minimum: 4
          )

          expect(record).
            to validate_length_of(:name).
            is_at_least(4).
            converting_values("xxx" => "XXX", "xxxx" => "XXXX")
        end
      end
    end
  end

  context 'an attribute with a minimum length validation of 0' do
    it 'accepts ensuring the correct minimum length' do
      expect(validating_length(minimum: 0)).
        to validate_length_of(:attr).is_at_least(0)
    end

    context 'when the writer method for the attribute changes incoming values' do
      context 'and the matcher knows nothing of this' do
        it 'raises a CouldNotSetAttributeError' do
          pending 'this should test that name accepts values > 0 length but does not'

          record = build_record_validating_length(
            attribute_name: :name,
            convert_attribute_with: :upcase,
            minimum: 0
          )

          assertion = lambda do
            expect(record).to validate_length_of(:name).is_at_least(0)
          end

          expect(&assertion).to raise_error(
            Shoulda::Matchers::ActiveModel::AllowValueMatcher::CouldNotSetAttributeError
          )
        end
      end

      context 'and the matcher knows how given values get changed' do
        it 'accepts (and not raise an error)' do
          record = build_record_validating_length(
            attribute_name: :name,
            convert_attribute_with: :upcase,
            minimum: 0
          )

          expect(record).
            to validate_length_of(:name).
            is_at_least(0).
            converting_values("x" => "X")
        end
      end
    end
  end

  context 'an attribute with a maximum length' do
    it 'accepts ensuring the correct maximum length' do
      expect(validating_length(maximum: 4)).
        to validate_length_of(:attr).is_at_most(4)
    end

    it 'rejects ensuring a lower maximum length with any message' do
      expect(validating_length(maximum: 4)).
        not_to validate_length_of(:attr).is_at_most(3).with_long_message(/.*/)
    end

    it 'rejects ensuring a higher maximum length with any message' do
      expect(validating_length(maximum: 4)).
        not_to validate_length_of(:attr).is_at_most(5).with_long_message(/.*/)
    end

    it 'does not override the default message with a blank' do
      expect(validating_length(maximum: 4)).
        to validate_length_of(:attr).is_at_most(4).with_long_message(nil)
    end

    context 'when the writer method for the attribute changes incoming values' do
      context 'and the matcher knows nothing of this' do
        it 'raises a CouldNotSetAttributeError' do
          record = build_record_validating_length(
            attribute_name: :name,
            convert_attribute_with: :upcase,
            maximum: 4
          )

          assertion = lambda do
            expect(record).to validate_length_of(:name).is_at_most(4)
          end

          expect(&assertion).to raise_error(
            Shoulda::Matchers::ActiveModel::AllowValueMatcher::CouldNotSetAttributeError
          )
        end
      end

      context 'and the matcher knows how given values get changed' do
        it 'accepts (and not raise an error)' do
          record = build_record_validating_length(
            attribute_name: :name,
            convert_attribute_with: :upcase,
            maximum: 4
          )

          expect(record).
            to validate_length_of(:name).
            is_at_most(4).
            converting_values('xxxx' => 'XXXX', 'xxxxx' => 'XXXXX')
        end
      end
    end
  end

  context 'an attribute with a required exact length' do
    it 'accepts ensuring the correct length' do
      expect(validating_length(is: 4)).
        to validate_length_of(:attr).is_equal_to(4)
    end

    it 'rejects ensuring a lower maximum length with any message' do
      expect(validating_length(is: 4)).
        not_to validate_length_of(:attr).is_equal_to(3).with_message(/.*/)
    end

    it 'rejects ensuring a higher maximum length with any message' do
      expect(validating_length(is: 4)).
        not_to validate_length_of(:attr).is_equal_to(5).with_message(/.*/)
    end

    it 'does not override the default message with a blank' do
      expect(validating_length(is: 4)).
        to validate_length_of(:attr).is_equal_to(4).with_message(nil)
    end

    context 'when the writer method for the attribute changes incoming values' do
      context 'and the matcher knows nothing of this' do
        it 'raises a CouldNotSetAttributeError' do
          record = build_record_validating_length(
            attribute_name: :name,
            convert_attribute_with: :upcase,
            is: 4
          )

          assertion = lambda do
            expect(record).to validate_length_of(:name).is_equal_to(4)
          end

          expect(&assertion).to raise_error(
            Shoulda::Matchers::ActiveModel::AllowValueMatcher::CouldNotSetAttributeError
          )
        end
      end

      context 'and the matcher knows how given values get changed' do
        it 'accepts (and not raise an error)' do
          record = build_record_validating_length(
            attribute_name: :name,
            convert_attribute_with: :upcase,
            is: 4
          )

          expect(record).
            to validate_length_of(:name).
            is_equal_to(4).
            converting_values(
              'xxx' => 'XXX',
              'xxxx' => 'XXXX',
              'xxxxx' => 'XXXXX'
            )
        end
      end
    end
  end

  context 'an attribute with a required exact length and another validation' do
    it 'accepts ensuring the correct length' do
      model = define_model(:example, attr: :string) do
        validates_length_of :attr, is: 4
        validates_numericality_of :attr
      end.new

      expect(model).to validate_length_of(:attr).is_equal_to(4)
    end
  end

  context 'an attribute with a custom minimum length validation' do
    it 'accepts ensuring the correct minimum length' do
      expect(validating_length(minimum: 4, too_short: 'foobar')).
        to validate_length_of(:attr).is_at_least(4).with_short_message(/foo/)
    end
  end

  context 'an attribute with a custom maximum length validation' do
    it 'accepts ensuring the correct minimum length' do
      expect(validating_length(maximum: 4, too_long: 'foobar')).
        to validate_length_of(:attr).is_at_most(4).with_long_message(/foo/)
    end
  end

  context 'an attribute with a custom equal validation' do
    it 'accepts ensuring the correct exact length' do
      expect(validating_length(is: 4, message: 'foobar')).
        to validate_length_of(:attr).is_equal_to(4).with_message(/foo/)
    end
  end

  context 'an attribute without a length validation' do
    it 'rejects ensuring a minimum length' do
      expect(define_model(:example, attr: :string).new).
        not_to validate_length_of(:attr).is_at_least(1)
    end
  end

  context 'using translations' do
    after { I18n.backend.reload! }

    context "a too_long translation containing %{attribute}, %{model}" do
      before do
        stub_translation(
          "activerecord.errors.messages.too_long",
          "The %{attribute} of your %{model} is too long (maximum is %{count} characters)")
      end

      it "does not raise an exception" do
        expect {
          expect(validating_length(maximum: 4)).
            to validate_length_of(:attr).is_at_most(4)
        }.to_not raise_exception
      end
    end

    context "a too_short translation containing %{attribute}, %{model}" do
      before do
        stub_translation(
          "activerecord.errors.messages.too_short",
          "The %{attribute} of your %{model} is too short (minimum is %{count} characters)")
      end

      it "does not raise an exception" do
        expect {
          expect(validating_length(minimum: 4)).to validate_length_of(:attr).is_at_least(4)
        }.to_not raise_exception
      end
    end

    context "a wrong_length translation containing %{attribute}, %{model}" do
      before do
        stub_translation(
          "activerecord.errors.messages.wrong_length",
          "The %{attribute} of your %{model} is the wrong length (should be %{count} characters)")
      end

      it "does not raise an exception" do
        expect {
          expect(validating_length(is: 4)).
            to validate_length_of(:attr).is_equal_to(4)
        }.to_not raise_exception
      end
    end
  end

  def define_model_validating_length(options = {})
    options = options.dup
    attribute_name = options.delete(:attribute_name) { :attr }

    define_model(:example, attribute_name => :string) do |model|
      model.validates_length_of(attribute_name, options)

      if options.key?(:convert_attribute_with)
        model.send(:define_method, "#{attribute_name}=") do |value|
          super(value.send(options[:convert_attribute_with]))
        end
      end
    end
  end

  def validating_length(options = {})
    define_model_validating_length(options).new
  end

  alias_method :build_record_validating_length, :validating_length
end
