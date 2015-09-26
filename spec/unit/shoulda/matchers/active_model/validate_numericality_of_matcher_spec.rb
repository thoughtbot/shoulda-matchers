require 'unit_spec_helper'

describe Shoulda::Matchers::ActiveModel::ValidateNumericalityOfMatcher, type: :model do
  class << self
    def all_qualifiers
      [
        {
          category: :comparison,
          name: :is_greater_than,
          argument: 1,
          validation_name: :greater_than,
          validation_value: 1,
        },
        {
          category: :comparison,
          name: :is_greater_than_or_equal_to,
          argument: 1,
          validation_name: :greater_than_or_equal_to,
          validation_value: 1,
        },
        {
          category: :comparison,
          name: :is_less_than,
          argument: 1,
          validation_name: :less_than,
          validation_value: 1,
        },
        {
          category: :comparison,
          name: :is_less_than_or_equal_to,
          argument: 1,
          validation_name: :less_than_or_equal_to,
          validation_value: 1,
        },
        {
          category: :comparison,
          name: :is_equal_to,
          argument: 1,
          validation_name: :equal_to,
          validation_value: 1,
        },
        {
          category: :cardinality,
          name: :odd,
          validation_name: :odd,
          validation_value: true,
        },
        {
          category: :cardinality,
          name: :even,
          validation_name: :even,
          validation_value: true,
        },
        {
          name: :only_integer,
          validation_name: :only_integer,
          validation_value: true,
        },
        {
          name: :on,
          argument: :customizable,
          validation_name: :on,
          validation_value: :customizable
        }
      ]
    end

    def qualifiers_under(category)
      all_qualifiers.select do |qualifier|
        qualifier[:category] == category
      end
    end

    def mutually_exclusive_qualifiers
      qualifiers_under(:cardinality) + qualifiers_under(:comparison)
    end

    def non_mutually_exclusive_qualifiers
      all_qualifiers - mutually_exclusive_qualifiers
    end

    def validations_by_qualifier
      all_qualifiers.each_with_object({}) do |qualifier, hash|
        hash[qualifier[:name]] = qualifier[:validation_name]
      end
    end

    def all_qualifier_combinations
      combinations = []

      ([nil] + mutually_exclusive_qualifiers).each do |mutually_exclusive_qualifier|
        (0..non_mutually_exclusive_qualifiers.length).each do |n|
          non_mutually_exclusive_qualifiers.combination(n) do |combination|
            super_combination = (
              [mutually_exclusive_qualifier] +
              combination
            )
            super_combination.select!(&:present?)

            if super_combination.any?
              combinations << super_combination
            end
          end
        end
      end

      combinations
    end

    def default_qualifier_arguments
      all_qualifiers.each_with_object({}) do |qualifier, hash|
        hash[qualifier[:name]] = qualifier[:argument]
      end
    end

    def default_validation_values
      all_qualifiers.each_with_object({}) do |qualifier, hash|
        hash[qualifier[:validation_name]] = qualifier[:validation_value]
      end
    end
  end

  context 'qualified with nothing' do
    context 'and validating numericality' do
      it 'accepts' do
        record = build_record_validating_numericality
        expect(record).to validate_numericality
      end
    end

    context 'and not validating anything' do
      it 'rejects since it does not disallow non-numbers' do
        record = build_record_validating_nothing
        assertion = -> { expect(record).to validate_numericality }
        expect(&assertion).to fail_with_message_including(
          'Expected errors to include "is not a number"'
        )
      end
    end
  end

  context 'qualified with allow_nil' do
    context 'and validating with allow_nil' do
      it 'accepts' do
        record = build_record_validating_numericality(allow_nil: true)
        expect(record).to validate_numericality.allow_nil
      end
    end

    context 'and not validating with allow_nil' do
      it 'rejects since it tries to treat nil as a number' do
        record = build_record_validating_numericality
        assertion = lambda do
          expect(record).to validate_numericality.allow_nil
        end
        expect(&assertion).to fail_with_message_including(
          %[Did not expect errors to include "is not a number" when #{attribute_name} is set to nil]
        )
      end
    end
  end

  context 'qualified with only_integer' do
    context 'and validating with only_integer' do
      it 'accepts' do
        record = build_record_validating_numericality(only_integer: true)
        expect(record).to validate_numericality.only_integer
      end
    end

    context 'and not validating with only_integer' do
      it 'rejects since it does not disallow non-integers' do
        record = build_record_validating_numericality
        assertion = lambda do
          expect(record).to validate_numericality.only_integer
        end
        expect(&assertion).to fail_with_message_including(
          'Expected errors to include "must be an integer"'
        )
      end
    end
  end

  context 'qualified with odd' do
    context 'and validating with odd' do
      it 'accepts' do
        record = build_record_validating_numericality(odd: true)
        expect(record).to validate_numericality.odd
      end
    end

    context 'and not validating with odd' do
      it 'rejects since it does not disallow even numbers' do
        record = build_record_validating_numericality
        assertion = lambda do
          expect(record).to validate_numericality.odd
        end
        expect(&assertion).to fail_with_message_including(
          'Expected errors to include "must be odd"'
        )
      end
    end
  end

  context 'qualified with even' do
    context 'and validating with even' do
      it 'allows even number values for that attribute' do
        record = build_record_validating_numericality(even: true)
        expect(record).to validate_numericality.even
      end
    end

    context 'and not validating with even' do
      it 'rejects since it does not disallow odd numbers' do
        record = build_record_validating_numericality
        assertion = -> { expect(record).to validate_numericality.even }
        expect(&assertion).to fail_with_message_including(
          'Expected errors to include "must be even"'
        )
      end
    end
  end

  context 'qualified with is_less_than_or_equal_to' do
    context 'and validating with less_than_or_equal_to' do
      it 'accepts' do
        record = build_record_validating_numericality(
          less_than_or_equal_to: 18
        )
        expect(record).to validate_numericality.is_less_than_or_equal_to(18)
      end
    end

    context 'and not validating with less_than_or_equal_to' do
      it 'rejects since it does not disallow numbers greater than the value' do
        record = build_record_validating_numericality
        assertion = lambda do
          expect(record).
            to validate_numericality.
            is_less_than_or_equal_to(18)
        end
        expect(&assertion).to fail_with_message_including(
          'Expected errors to include "must be less than or equal to 18"'
        )
      end
    end
  end

  context 'qualified with is_less_than' do
    context 'and validating with less_than' do
      it 'accepts' do
        record = build_record_validating_numericality(less_than: 18)
        expect(record).
          to validate_numericality.
          is_less_than(18)
      end
    end

    context 'and not validating with less_than' do
      it 'rejects since it does not disallow numbers greater than or equal to the value' do
        record = build_record_validating_numericality
        assertion = lambda do
          expect(record).
            to validate_numericality.
            is_less_than(18)
        end
        expect(&assertion).to fail_with_message_including(
          'Expected errors to include "must be less than 18"'
        )
      end
    end
  end

  context 'qualified with is_equal_to' do
    context 'and validating with equal_to' do
      it 'accepts' do
        record = build_record_validating_numericality(equal_to: 18)
        expect(record).to validate_numericality.is_equal_to(18)
      end
    end

    context 'and not validating with equal_to' do
      it 'rejects since it does not disallow numbers that are not the value' do
        record = build_record_validating_numericality
        assertion = lambda do
          expect(record).to validate_numericality.is_equal_to(18)
        end
        expect(&assertion).to fail_with_message_including(
          'Expected errors to include "must be equal to 18"'
        )
      end
    end
  end

  context 'qualified with is_greater_than_or_equal to' do
    context 'validating with greater_than_or_equal_to' do
      it 'accepts' do
        record = build_record_validating_numericality(
          greater_than_or_equal_to: 18
        )
        expect(record).
          to validate_numericality.
          is_greater_than_or_equal_to(18)
      end
    end

    context 'not validating with greater_than_or_equal_to' do
      it 'rejects since it does not disallow numbers that are less than the value' do
        record = build_record_validating_numericality
        assertion = lambda do
          expect(record).
            to validate_numericality.
            is_greater_than_or_equal_to(18)
        end
        expect(&assertion).to fail_with_message_including(
          'Expected errors to include "must be greater than or equal to 18"'
        )
      end
    end
  end

  context 'qualified with is_greater_than' do
    context 'and validating with greater_than' do
      it 'accepts' do
        record = build_record_validating_numericality(greater_than: 18)
        expect(record).
          to validate_numericality.
          is_greater_than(18)
      end
    end

    context 'and not validating with greater_than' do
      it 'rejects since it does not disallow numbers that are less than or equal to the value' do
        record = build_record_validating_numericality
        assertion = lambda do
          expect(record).
            to validate_numericality.
            is_greater_than(18)
        end
        expect(&assertion).to fail_with_message_including(
          'Expected errors to include "must be greater than 18"'
        )
      end
    end
  end

  context 'qualified with with_message' do
    context 'and validating with the same message' do
      it 'accepts' do
        record = build_record_validating_numericality(message: 'custom')
        expect(record).to validate_numericality.with_message(/custom/)
      end
    end

    context 'and validating with a different message' do
      it 'rejects' do
        record = build_record_validating_numericality(message: 'custom')
        expect(record).not_to validate_numericality.with_message(/wrong/)
      end
    end

    context 'and no message is provided' do
      it 'ignores the qualifier' do
        record = build_record_validating_numericality
        expect(record).to validate_numericality.with_message(nil)
      end
    end
  end

  context 'qualified with strict' do
    context 'and validating strictly' do
      it 'accepts' do
        record = build_record_validating_numericality(strict: true)
        expect(record).to validate_numericality.strict
      end
    end

    context 'and not validating strictly' do
      it 'rejects since ActiveModel::StrictValidationFailed is never raised' do
        record = build_record_validating_numericality(attribute_name: :attr)
        assertion = lambda do
          expect(record).to validate_numericality_of(:attr).strict
        end
        expect(&assertion).to fail_with_message_including(
          'Expected exception to include "Attr is not a number"'
        )
      end
    end
  end

  context 'qualified with on and validating with on' do
    it 'accepts' do
      record = build_record_validating_numericality(on: :customizable)
      expect(record).to validate_numericality.on(:customizable)
    end
  end

  context 'qualified with on but not validating with on' do
    it 'accepts since the validation never considers a context' do
      record = build_record_validating_numericality
      expect(record).to validate_numericality.on(:customizable)
    end
  end

  context 'not qualified with on but validating with on' do
    it 'rejects since the validation never runs' do
      record = build_record_validating_numericality(on: :customizable)
      assertion = lambda do
        expect(record).to validate_numericality
      end
      expect(&assertion).to fail_with_message_including(
        'Expected errors to include "is not a number"'
      )
    end
  end

  context 'with combinations of qualifiers together' do
    all_qualifier_combinations.each do |combination|
      if combination.size > 1
        it do
          validation_options = build_validation_options(for: combination)
          record = build_record_validating_numericality(validation_options)
          validate_numericality = self.validate_numericality
          apply_qualifiers!(for: combination, to: validate_numericality)
          expect(record).to validate_numericality
        end
      end
    end

    context 'when the qualifiers do not match the validation options' do
      specify 'such as validating even but testing that only_integer is validated' do
        record = build_record_validating_numericality(
          even: true,
          greater_than: 18
        )
        assertion = lambda do
          expect(record).
            to validate_numericality.
            only_integer.
            is_greater_than(18)
        end
        message = <<-MESSAGE.strip_heredoc
          Expected errors to include "must be an integer" when attr is set to "0.1",
          got errors:
          * "must be greater than 18" (attribute: attr, value: "0.1")
        MESSAGE
        expect(&assertion).to fail_with_message(message)
      end

      specify 'such as not validating only_integer but testing that only_integer is validated' do
        record = build_record_validating_numericality(greater_than: 18)
        assertion = lambda do
          expect(record).
            to validate_numericality.
            only_integer.
            is_greater_than(18)
        end
        message = <<-MESSAGE.strip_heredoc
          Expected errors to include "must be an integer" when attr is set to "0.1",
          got errors:
          * "must be greater than 18" (attribute: attr, value: "0.1")
        MESSAGE
        expect(&assertion).to fail_with_message(message)
      end

      specify 'such as validating greater_than_or_equal_to (+ even) but testing that greater_than is validated' do
        record = build_record_validating_numericality(
          even: true,
          greater_than_or_equal_to: 18
        )
        assertion = lambda do
          expect(record).
            to validate_numericality.
            even.
            is_greater_than(18)
        end
        message = <<-MESSAGE.strip_heredoc
          Expected errors to include "must be greater than 18" when attr is set to "18",
          got no errors
        MESSAGE
        expect(&assertion).to fail_with_message(message)
      end

      specify 'such as validating odd (+ greater_than) but testing that even is validated' do
        record = build_record_validating_numericality(
          odd: true,
          greater_than: 18
        )
        assertion = lambda do
          expect(record).
            to validate_numericality.
            even.
            is_greater_than(18)
        end
        message = <<-MESSAGE.strip_heredoc
          Expected errors to include "must be even" when attr is set to "1",
          got errors:
          * "must be greater than 18" (attribute: attr, value: "1")
        MESSAGE
        expect(&assertion).to fail_with_message(message)
      end

      specify 'such as validating greater_than_or_equal_to (+ odd) but testing that is_less_than_or_equal_to is validated' do
        record = build_record_validating_numericality(
          odd: true,
          greater_than_or_equal_to: 99
        )
        assertion = lambda do
          expect(record).
            to validate_numericality.
            odd.
            is_less_than_or_equal_to(99)
        end
        message = <<-MESSAGE.strip_heredoc
          Expected errors to include "must be less than or equal to 99" when attr is set to "101",
          got no errors
        MESSAGE
        expect(&assertion).to fail_with_message(message)
      end

      specify 'such as validating greater_than_or_equal_to (+ only_integer + less_than) but testing that greater_than is validated' do
        record = build_record_validating_numericality(
          only_integer: true,
          greater_than_or_equal_to: 18,
          less_than: 99
        )
        assertion = lambda do
          expect(record).
            to validate_numericality.
            only_integer.
            is_greater_than(18).
            is_less_than(99)
        end
        message = <<-MESSAGE.strip_heredoc
          Expected errors to include "must be greater than 18" when attr is set to "18",
          got no errors
        MESSAGE
        expect(&assertion).to fail_with_message(message)
      end
    end

    context 'when qualifiers match the validation options but the values are different' do
      specify 'such as testing greater_than (+ only_integer) with lower value' do
        record = build_record_validating_numericality(
          only_integer: true,
          greater_than: 19
        )
        assertion = lambda do
          expect(record).
            to validate_numericality.
            only_integer.
            is_greater_than(18)
        end
        message = <<-MESSAGE.strip_heredoc
          Expected errors to include "must be greater than 18" when attr is set to "18",
          got errors:
          * "must be greater than 19" (attribute: attr, value: "19")
        MESSAGE
        expect(&assertion).to fail_with_message(message)
      end

      specify 'such as testing greater_than (+ only_integer) with higher value' do
        record = build_record_validating_numericality(
          only_integer: true,
          greater_than: 17
        )
        assertion = lambda do
          expect(record).
            to validate_numericality.
            only_integer.
            is_greater_than(18)
        end
        message = <<-MESSAGE.strip_heredoc
          Expected errors to include "must be greater than 18" when attr is set to "18",
          got no errors
        MESSAGE
        expect(&assertion).to fail_with_message(message)
      end

      specify 'such as testing greater_than (+ even) with lower value' do
        record = build_record_validating_numericality(
          even: true,
          greater_than: 20
        )
        assertion = lambda do
          expect(record).
            to validate_numericality.
            even.
            is_greater_than(18)
        end
        message = <<-MESSAGE.strip_heredoc
          Expected errors to include "must be greater than 18" when attr is set to "18",
          got errors:
          * "must be greater than 20" (attribute: attr, value: "20")
        MESSAGE
        expect(&assertion).to fail_with_message(message)
      end

      specify 'such as testing greater than (+ even) with higher value' do
        record = build_record_validating_numericality(
          even: true,
          greater_than: 16
        )
        assertion = lambda do
          expect(record).
            to validate_numericality.
            even.
            is_greater_than(18)
        end
        message = <<-MESSAGE.strip_heredoc
          Expected errors to include "must be greater than 18" when attr is set to "18",
          got no errors
        MESSAGE
        expect(&assertion).to fail_with_message(message)
      end

      specify 'such as testing less_than_or_equal_to (+ odd) with lower value' do
        record = build_record_validating_numericality(
          odd: true,
          less_than_or_equal_to: 101
        )
        assertion = lambda do
          expect(record).
            to validate_numericality.
            odd.
            is_less_than_or_equal_to(99)
        end
        message = <<-MESSAGE.strip_heredoc
          Expected errors to include "must be less than or equal to 99" when attr is set to "101",
          got no errors
        MESSAGE
        expect(&assertion).to fail_with_message(message)
      end

      specify 'such as testing less_than_or_equal_to (+ odd) with higher value' do
        record = build_record_validating_numericality(
          odd: true,
          less_than_or_equal_to: 97
        )
        assertion = lambda do
          expect(record).
            to validate_numericality.
            odd.
            is_less_than_or_equal_to(99)
        end
        message = <<-MESSAGE.strip_heredoc
          Expected errors to include "must be less than or equal to 99" when attr is set to "101",
          got errors:
          * "must be less than or equal to 97" (attribute: attr, value: "101")
        MESSAGE
        expect(&assertion).to fail_with_message(message)
      end

      specify 'such as testing greater_than (+ only_integer + less_than) with lower value' do
        record = build_record_validating_numericality(
          only_integer: true,
          greater_than: 19,
          less_than: 99
        )
        assertion = lambda do
          expect(record).
            to validate_numericality.
            only_integer.
            is_greater_than(18).
            is_less_than(99)
        end
        message = <<-MESSAGE.strip_heredoc
          Expected errors to include "must be greater than 18" when attr is set to "18",
          got errors:
          * "must be greater than 19" (attribute: attr, value: "19")
        MESSAGE
        expect(&assertion).to fail_with_message(message)
      end

      specify 'such as testing less_than (+ only_integer + greater_than) with higher value' do
        record = build_record_validating_numericality(
          only_integer: true,
          greater_than: 18,
          less_than: 100
        )
        assertion = lambda do
          expect(record).
            to validate_numericality.
            only_integer.
            is_greater_than(18).
            is_less_than(99)
        end
        message = <<-MESSAGE.strip_heredoc
          Expected errors to include "must be less than 99" when attr is set to "100",
          got errors:
          * "must be less than 100" (attribute: attr, value: "100")
        MESSAGE
        expect(&assertion).to fail_with_message(message)
      end
    end
  end

  context 'with large numbers' do
    it do
      record = build_record_validating_numericality(greater_than: 100_000)
      expect(record).to validate_numericality.is_greater_than(100_000)
    end

    it do
      record = build_record_validating_numericality(less_than: 100_000)
      expect(record).to validate_numericality.is_less_than(100_000)
    end

    it do
      record = build_record_validating_numericality(
        greater_than_or_equal_to: 100_000
      )
      expect(record).
        to validate_numericality.
        is_greater_than_or_equal_to(100_000)
    end

    it do
      record = build_record_validating_numericality(
        less_than_or_equal_to: 100_000
      )
      expect(record).
        to validate_numericality.
        is_less_than_or_equal_to(100_000)
    end
  end

  context 'when the subject is stubbed' do
    it 'retains that stub while the validate_numericality is matching' do
      model = define_model :example, attr: :string do
        validates_numericality_of :attr, odd: true
        before_validation :set_attr!
        def set_attr!; self.attr = 5 end
      end

      record = model.new
      allow(record).to receive(:set_attr!)

      expect(record).to validate_numericality_of(:attr).odd
    end
  end

  describe '#description' do
    context 'qualified with nothing' do
      it 'describes that it allows numbers' do
        matcher = validate_numericality_of(:attr)
        expect(matcher.description).to eq 'only allow numbers for attr'
      end
    end

    context 'qualified with only_integer' do
      it 'describes that it allows integers' do
        matcher = validate_numericality_of(:attr).only_integer
        expect(matcher.description).to eq 'only allow integers for attr'
      end
    end

    qualifiers_under(:cardinality).each do |qualifier|
      context "qualified with #{qualifier[:name]}" do
        it "describes that it allows #{qualifier[:name]} numbers" do
          matcher = validate_numericality_of(:attr).__send__(qualifier[:name])
          expect(matcher.description).
            to eq "only allow #{qualifier[:name]} numbers for attr"
        end
      end
    end

    qualifiers_under(:comparison).each do |qualifier|
      comparison_phrase = qualifier[:validation_name].to_s.gsub('_', ' ')

      context "qualified with #{qualifier[:name]}" do
        it "describes that it allows numbers #{comparison_phrase} a certain value" do
          matcher = validate_numericality_of(:attr).
            __send__(qualifier[:name], 18)

          expect(matcher.description).to eq(
            "only allow numbers for attr which are #{comparison_phrase} 18"
          )
        end
      end
    end

    context 'qualified with odd + is_greater_than_or_equal_to' do
      it "describes that it allows odd numbers greater than or equal to a certain value" do
        matcher = validate_numericality_of(:attr).
          odd.
          is_greater_than_or_equal_to(18)

        expect(matcher.description).to eq(
          'only allow odd numbers for attr which are greater than or equal to 18'
        )
      end
    end

    context 'qualified with only integer + is_greater_than + less_than_or_equal_to' do
      it 'describes that it allows integer greater than one value and less than or equal to another' do
        matcher = validate_numericality_of(:attr).
          only_integer.
          is_greater_than(18).
          is_less_than_or_equal_to(100)

        expect(matcher.description).to eq(
          'only allow integers for attr which are greater than 18 and less than or equal to 100'
        )
      end
    end

    context 'qualified with strict' do
      it 'describes that it relies upon a strict validation' do
        matcher = validate_numericality_of(:attr).strict
        expect(matcher.description).to eq(
          'only allow numbers for attr, strictly'
        )
      end

      context 'and qualified with a comparison qualifier' do
        it 'places the comparison description after "strictly"' do
          matcher = validate_numericality_of(:attr).is_less_than(18).strict
          expect(matcher.description).to eq(
            'only allow numbers for attr, strictly, which are less than 18'
          )
        end
      end
    end
  end

  def build_validation_options(args)
    combination = args.fetch(:for)

    combination.each_with_object({}) do |qualifier, hash|
      value = self.class.default_validation_values.fetch(qualifier[:validation_name])
      hash[qualifier[:validation_name]] = value
    end
  end

  def apply_qualifiers!(args)
    combination = args.fetch(:for)
    matcher = args.fetch(:to)

    combination.each do |qualifier|
      args = self.class.default_qualifier_arguments.fetch(qualifier[:name])
      matcher.__send__(qualifier[:name], *args)
    end
  end

  def define_model_validating_numericality(options = {})
    attribute_name = options.delete(:attribute_name) { self.attribute_name }

    define_model 'Example', attribute_name => :string do |model|
      model.validates_numericality_of(attribute_name, options)
    end
  end

  def build_record_validating_numericality(options = {})
    define_model_validating_numericality(options).new
  end

  def define_model_validating_nothing
    define_model('Example', attribute_name => :string)
  end

  def build_record_validating_nothing
    define_model_validating_nothing.new
  end

  def validate_numericality
    validate_numericality_of(attribute_name)
  end

  def attribute_name
    :attr
  end
end
