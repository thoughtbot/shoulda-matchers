require 'unit_spec_helper'

describe Shoulda::Matchers::MatcherCollection do
  let(:fake_matcher_class) do
    Class.new do
      attr_reader :description, :failure_reason, :some_qualifier

      def initialize(
        description:,
        matches: true,
        does_not_match: !matches,
        failure_reason: nil
      )
        @description = description
        @matches = matches
        @does_not_match = does_not_match
        @failure_reason = failure_reason
      end

      def matches?(_subject)
        @matches
      end

      def does_not_match?(_subject)
        @does_not_match
      end

      def with_some_qualifier(value)
        @some_qualifier = value
        self
      end
    end
  end

  let(:fake_subject_class) do
    Class.new do
      def self.name
        'Example'
      end
    end
  end

  describe '#description' do
    it 'joins each wrapped matcher description with " and "' do
      collection = described_class.new(
        [
          fake_matcher_class.new(description: 'do A'),
          fake_matcher_class.new(description: 'do B'),
        ],
      )

      expect(collection.description).to eq('do A and do B')
    end
  end

  describe '#matches?' do
    it 'returns true when every wrapped matcher matches' do
      collection = described_class.new(
        [
          fake_matcher_class.new(description: 'do A', matches: true),
          fake_matcher_class.new(description: 'do B', matches: true),
        ],
      )

      expect(collection.matches?(fake_subject_class.new)).to be(true)
    end

    it 'returns false when any wrapped matcher does not match' do
      collection = described_class.new(
        [
          fake_matcher_class.new(description: 'do A', matches: true),
          fake_matcher_class.new(description: 'do B', matches: false),
        ],
      )

      expect(collection.matches?(fake_subject_class.new)).to be(false)
    end
  end

  describe '#does_not_match?' do
    it 'returns true when no wrapped matcher matches' do
      collection = described_class.new(
        [
          fake_matcher_class.new(description: 'do A', does_not_match: true),
          fake_matcher_class.new(description: 'do B', does_not_match: true),
        ],
      )

      expect(collection.does_not_match?(fake_subject_class.new)).to be(true)
    end

    it 'returns false when any wrapped matcher matches' do
      collection = described_class.new(
        [
          fake_matcher_class.new(description: 'do A', does_not_match: true),
          fake_matcher_class.new(description: 'do B', does_not_match: false),
        ],
      )

      expect(collection.does_not_match?(fake_subject_class.new)).to be(false)
    end
  end

  describe '#failure_message' do
    it 'lists every failed matcher in the header and each reason' do
      collection = described_class.new(
        [
          fake_matcher_class.new(
            description: 'do A',
            matches: false,
            failure_reason: 'A failed because of X',
          ),
          fake_matcher_class.new(
            description: 'do B',
            matches: false,
            failure_reason: 'B failed because of Y',
          ),
        ],
      )
      collection.matches?(fake_subject_class.new)

      expect(collection.failure_message).to eq(<<~MESSAGE.chomp)
        Expected Example to do A and do B, but this could not be proved.
          A failed because of X
          B failed because of Y
      MESSAGE
    end

    it 'only mentions failed matchers when some wrapped matchers pass' do
      collection = described_class.new(
        [
          fake_matcher_class.new(description: 'do A', matches: true),
          fake_matcher_class.new(
            description: 'do B',
            matches: false,
            failure_reason: 'B failed',
          ),
        ],
      )
      collection.matches?(fake_subject_class.new)

      expect(collection.failure_message).to eq(<<~MESSAGE.chomp)
        Expected Example to do B, but this could not be proved.
          B failed
      MESSAGE
    end

    it 'omits the reason block for matchers whose failure_reason is blank' do
      collection = described_class.new(
        [
          fake_matcher_class.new(
            description: 'do A',
            matches: false,
            failure_reason: nil,
          ),
          fake_matcher_class.new(
            description: 'do B',
            matches: false,
            failure_reason: nil,
          ),
        ],
      )
      collection.matches?(fake_subject_class.new)

      expect(collection.failure_message).to eq(
        'Expected Example to do A and do B, but this could not be proved.',
      )
    end

    it 'delegates to the wrapped matcher when only one matcher is present' do
      single_matcher = fake_matcher_class.new(
        description: 'do A',
        matches: false,
        failure_reason: 'A failed',
      )
      def single_matcher.failure_message
        'custom failure message'
      end
      collection = described_class.new([single_matcher])
      collection.matches?(fake_subject_class.new)

      expect(collection.failure_message).to eq('custom failure message')
    end
  end

  describe '#failure_message_when_negated' do
    it 'uses "not to" in the header and lists each matcher reason' do
      collection = described_class.new(
        [
          fake_matcher_class.new(
            description: 'do A',
            does_not_match: false,
            failure_reason: 'A still matched',
          ),
          fake_matcher_class.new(
            description: 'do B',
            does_not_match: false,
            failure_reason: 'B still matched',
          ),
        ],
      )
      collection.does_not_match?(fake_subject_class.new)

      expect(collection.failure_message_when_negated).to eq(<<~MESSAGE.chomp)
        Expected Example not to do A and do B, but this could not be proved.
          A still matched
          B still matched
      MESSAGE
    end

    it 'delegates to the wrapped matcher when only one matcher is present' do
      single_matcher = fake_matcher_class.new(
        description: 'do A',
        does_not_match: false,
      )
      def single_matcher.failure_message_when_negated
        'custom negated message'
      end
      collection = described_class.new([single_matcher])
      collection.does_not_match?(fake_subject_class.new)

      expect(collection.failure_message_when_negated).to eq('custom negated message')
    end
  end

  describe 'qualifier delegation' do
    it 'forwards an unknown method to every wrapped matcher when all respond' do
      matchers = [
        fake_matcher_class.new(description: 'do A'),
        fake_matcher_class.new(description: 'do B'),
      ]
      collection = described_class.new(matchers)

      result = collection.with_some_qualifier(:foo)

      expect(matchers.map(&:some_qualifier)).to eq([:foo, :foo])
      expect(result).to be(collection)
    end

    it 'raises NoMethodError when not every wrapped matcher responds' do
      collection = described_class.new(
        [fake_matcher_class.new(description: 'do A')],
      )

      expect { collection.totally_unknown_qualifier }.
        to raise_error(NoMethodError)
    end
  end
end
