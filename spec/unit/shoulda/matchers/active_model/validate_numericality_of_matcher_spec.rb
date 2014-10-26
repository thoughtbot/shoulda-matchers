require 'spec_helper'

describe Shoulda::Matchers::ActiveModel::ValidateNumericalityOfMatcher do

  context 'with a model with a numericality validation' do
    it 'accepts' do
      expect(validating_numericality).to matcher
    end

    it 'does not override the default message with a blank' do
      expect(validating_numericality).to matcher.with_message(nil)
    end
  end

  context 'with a model without a numericality validation' do
    it 'rejects' do
      expect(not_validating_numericality).not_to matcher
    end

    it 'rejects with the ActiveRecord :not_a_number message' do
      the_matcher = matcher

      the_matcher.matches?(define_model(:example, attr: :string).new)

      expect(the_matcher.failure_message_when_negated)
        .to include 'Did not expect errors to include "is not a number"'
    end

    it 'rejects with the ActiveRecord :not_an_integer message' do
      the_matcher = matcher.only_integer
      expect do
        expect(not_validating_numericality).to the_matcher
      end.to fail_with_message_including(
        'Expected errors to include "must be an integer"'
      )
    end

    it 'rejects with the ActiveRecord :odd message' do
      the_matcher = matcher.odd
      expect do
        expect(not_validating_numericality).to the_matcher
      end.to fail_with_message_including(
        'Expected errors to include "must be odd"'
      )
    end

    it 'rejects with the ActiveRecord :even message' do
      the_matcher = matcher.even
      expect do
        expect(not_validating_numericality).to the_matcher
      end.to fail_with_message_including(
        'Expected errors to include "must be even"'
      )
    end
  end

  context 'with the allow_nil option' do
    it 'allows nil values for that attribute' do
      expect(validating_numericality(allow_nil: true)).to matcher.allow_nil
    end

    it 'rejects when the model does not allow nil' do
      the_matcher = matcher.allow_nil
      expect {
        expect(validating_numericality).to the_matcher
      }.to fail_with_message_including('Did not expect errors to include "is not a number"')
    end
  end

  context 'with the only_integer option' do
    it 'allows integer values for that attribute' do
      expect(validating_numericality(only_integer: true)).to matcher.only_integer
    end

    it 'rejects when the model does not enforce integer values' do
      expect(validating_numericality).not_to matcher.only_integer
    end

    it 'rejects with the ActiveRecord :not_an_integer message' do
      the_matcher = matcher.only_integer
      expect do
        expect(validating_numericality).to the_matcher
      end.to fail_with_message_including(
        'Expected errors to include "must be an integer"'
      )
    end
  end

  context 'with the odd option' do
    it 'allows odd number values for that attribute' do
      expect(validating_numericality(odd: true)).to matcher.odd
    end

    it 'rejects when the model does not enforce odd number values' do
      expect(validating_numericality).not_to matcher.odd
    end

    it 'rejects with the ActiveRecord :odd message' do
      the_matcher = matcher.odd
      expect do
        expect(validating_numericality).to the_matcher
      end.to fail_with_message_including(
        'Expected errors to include "must be odd"'
      )
    end
  end

  context 'with the even option' do
    it 'allows even number values for that attribute' do
      expect(validating_numericality(even: true)).to matcher.even
    end

    it 'rejects when the model does not enforce even number values' do
      expect(validating_numericality).not_to matcher.even
    end

    it 'rejects with the ActiveRecord :even message' do
      the_matcher = matcher.even
      expect do
        expect(validating_numericality).to the_matcher
      end.to fail_with_message_including(
        'Expected errors to include "must be even"'
      )
    end
  end

  context 'with multiple options together' do
    context 'the success cases' do
      it do
        expect(validating_numericality(only_integer: true, greater_than: 18))
          .to matcher.only_integer.is_greater_than(18)
      end

      it do
        expect(validating_numericality(even: true, greater_than: 18))
          .to matcher.even.is_greater_than(18)
      end
      it do
        expect(validating_numericality(odd: true, less_than_or_equal_to: 99))
          .to matcher.odd.is_less_than_or_equal_to(99)
      end

      it do
        expect(validating_numericality(
                 only_integer: true,
                 greater_than: 18,
                 less_than: 99)
        ).to matcher.only_integer.is_greater_than(18).is_less_than(99)
      end
    end

    context 'the failure cases with different validators' do
      it do
        expect(validating_numericality(even: true, greater_than: 18))
          .not_to matcher.only_integer.is_greater_than(18)
      end

      it do
        expect(validating_numericality(greater_than: 18))
          .not_to matcher.only_integer.is_greater_than(18)
      end

      it do
        expect(
          validating_numericality(even: true, greater_than_or_equal_to: 18)
        ).not_to matcher.even.is_greater_than(18)
      end

      it do
        expect(validating_numericality(odd: true, greater_than: 18))
          .not_to matcher.even.is_greater_than(18)
      end

      it do
        expect(validating_numericality(
                 odd: true,
                 greater_than_or_equal_to: 99
               )
        ).not_to matcher.odd.is_less_than_or_equal_to(99)
      end

      it do
        expect(validating_numericality(
                 only_integer: true,
                 greater_than_or_equal_to: 18,
                 less_than: 99
               )
        ).not_to matcher.only_integer.is_greater_than(18).is_less_than(99)
      end
    end

    context 'the failure cases with wrong values' do
      it do
        expect(validating_numericality(only_integer: true, greater_than: 19))
          .not_to matcher.only_integer.is_greater_than(18)
      end

      it do
        expect(validating_numericality(only_integer: true, greater_than: 17))
          .not_to matcher.only_integer.is_greater_than(18)
      end

      it do
        expect(validating_numericality(even: true, greater_than: 20))
          .not_to matcher.even.is_greater_than(18)
      end

      it do
        expect(validating_numericality(even: true, greater_than: 16))
          .not_to matcher.even.is_greater_than(18)
      end

      it do
        expect(validating_numericality(odd: true, less_than_or_equal_to: 101))
         .not_to matcher.odd.is_less_than_or_equal_to(99)
      end

      it do
        expect(validating_numericality(odd: true, less_than_or_equal_to: 97))
          .not_to matcher.odd.is_less_than_or_equal_to(99)
      end

      it do
        expect(validating_numericality(only_integer: true,
                                          greater_than: 19,
                                          less_than: 99))
          .not_to matcher.only_integer.is_greater_than(18).is_less_than(99)
      end

      it do
        expect(validating_numericality(only_integer: true,
                                          greater_than: 18,
                                          less_than: 100))
          .not_to matcher.only_integer.is_greater_than(18).is_less_than(99)
      end
    end
  end

  context 'with large numbers' do
    it do
      expect(validating_numericality(greater_than: 100_000))
        .to matcher.is_greater_than(100_000)
    end

    it do
      expect(validating_numericality(less_than: 100_000))
        .to matcher.is_less_than(100_000)
    end

    it do
      expect(validating_numericality(greater_than_or_equal_to: 100_000))
        .to matcher.is_greater_than_or_equal_to(100_000)
    end

    it do
      expect(validating_numericality(less_than_or_equal_to: 100_000))
        .to matcher.is_less_than_or_equal_to(100_000)
    end
  end

  context 'with a custom validation message' do
    it 'accepts when the messages match' do
      expect(validating_numericality(message: 'custom')).
          to matcher.with_message(/custom/)
    end

    it 'rejects when the messages do not match' do
      expect(validating_numericality(message: 'custom')).
          not_to matcher.with_message(/wrong/)
    end
  end

  context 'when the subject is stubbed' do
    it 'retains stubs on submatchers' do
      subject = define_model :example, attr: :string do
        validates_numericality_of :attr, odd: true
        before_validation :set_attr!
        def set_attr!; self.attr = 5 end
      end.new

      subject.stubs(:set_attr!)
      expect(subject).to matcher.odd
    end
  end

  describe '#description' do
    context 'without submatchers' do
      it { expect(matcher.description).to eq 'only allow numbers for attr' }
    end

    context 'with only integer option' do
      it do
        expect(matcher.only_integer.description)
          .to eq 'only allow integers for attr'
      end
    end

    [:odd, :even].each do |type|
      context "with #{type} option" do
        it do
          expect(matcher.__send__(type).description)
            .to eq "only allow #{type} numbers for attr"
        end
      end
    end

    [:is_greater_than,
     :is_greater_than_or_equal_to,
     :is_less_than,
     :is_less_than_or_equal_to,
     :is_equal_to ].each do |comparison|
      context "with #{comparison} option" do
        it do
          expect(matcher.__send__(comparison, 18).description)
          .to eq(
            'only allow numbers for attr which are ' +
            "#{comparison.to_s.sub('is_', '').gsub('_', ' ')} 18"
          )
        end
      end
    end

    context 'with odd, is_greater_than_or_equal_to option' do
      it do
        expect(matcher.odd.is_greater_than_or_equal_to(18).description)
          .to eq(
            'only allow odd numbers for attr ' +
            'which are greater than or equal to 18'
          )
      end
    end

    context 'with only integer, is_greater_than and less_than_or_equal_to option' do
      it { expect(matcher.only_integer.is_greater_than(18).is_less_than_or_equal_to(100).description).
          to eq "only allow integers for attr which are greater than 18 and less than or equal to 100" }
    end
  end


  def validating_numericality(options = {})
    define_model :example, attr: :string do
      validates_numericality_of :attr, options
    end.new
  end

  def not_validating_numericality
    define_model(:example, attr: :string).new
  end

  def matcher
    validate_numericality_of(:attr)
  end
end
