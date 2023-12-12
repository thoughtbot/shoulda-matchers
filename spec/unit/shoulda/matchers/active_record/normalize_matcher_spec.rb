require 'unit_spec_helper'

describe Shoulda::Matchers::ActiveRecord::NormalizeMatcher, type: :model do
  if rails_version >= 7.1
    describe '#description' do
      it 'returns the message including the attribute names, from value and to value' do
        matcher = normalize(:name, :email).from("jane doe\n").to('Jane Doe')
        expect(matcher.description).
          to eq('normalize name and email from ‹"jane doe\n"› to ‹"Jane Doe"›')
      end
    end

    context 'when subject normalizes single attribute correctly' do
      it 'matches' do
        model = define_model(:User, email: :string) do
          normalizes :email, with: -> (email) { email.strip.downcase }
        end

        expect(model.new).to normalize(:email).from(" XyZ@EXAMPLE.com\n").to('xyz@example.com')
      end
    end

    context 'when subject normalizes multiple attributes correctly' do
      it 'matches' do
        model = define_model(:User, email: :string, name: :string) do
          normalizes :email, :name, with: -> (email) { email.strip.downcase }
        end

        expect(model.new).to normalize(:email, :name).from(" XyZ\n").to('xyz')
      end
    end

    context 'when subject normalizes single attribute incorrectly' do
      it 'fails' do
        model = define_model(:User, email: :string) do
          normalizes :email, with: -> (email) { email.titleize }
        end

        assertion = lambda do
          expect(model.new).to normalize(:email).from(" XyZ@EXAMPLE.com\n").to('xyz@example.com')
        end

        message = %(
          Expected to normalize :email from ‹" XyZ@EXAMPLE.com\\n"› to ‹"xyz@example.com"›
          but it was normalized to ‹"Xy Z@Example.Com\\n"›
        ).squish

        expect(&assertion).to fail_with_message(message)
      end
    end

    context 'when subject normalizes just one attribute incorrectly among multiple attributes' do
      it 'fails' do
        model = define_model(:User, email: :string, name: :string) do
          normalizes :name, with: -> (name) { name.titleize.strip }
          normalizes :email, with: -> (email) { email.downcase.strip }
        end

        assertion = lambda do
          expect(model.new).to normalize(:name, :email).from(" JaneDoe\n").to('Jane Doe')
        end

        message = %(
          Expected to normalize :email from ‹" JaneDoe\\n"› to ‹"Jane Doe"›
          but it was normalized to ‹"janedoe"›
        ).squish

        expect(&assertion).to fail_with_message(message)
      end
    end

    context 'when subject normalize nil values correctly' do
      it 'matches' do
        model = define_model(:User, name: :string) do
          normalizes :name, with: -> (name) { name&.strip || 'Untitled' }, apply_to_nil: true
        end

        record = model.new

        expect(record).to normalize(:name).from(' Jane Doe ').to('Jane Doe')
        expect(record).to normalize(:name).from(nil).to('Untitled')
      end
    end

    context "when subject doesn't normalize attribute that it shouldn't normalize" do
      it 'does not match' do
        model = define_model(:User, email: :string)

        expect(model.new).not_to normalize(:email).
          from(" XyZ@EXAMPLE.com\n").
          to('xyz@example.com')
      end
    end

    context "when subject normalizes attributes that it shouldn't normalize" do
      it 'fails' do
        model = define_model(:User, email: :string, name: :string) do
          normalizes :email, with: -> (email) { email.strip.downcase }
        end

        assertion = lambda do
          expect(model.new).not_to normalize(:name, :email).
            from(" XyZ@EXAMPLE.com\n").
            to('xyz@example.com')
        end

        message = %(
          Expected to not normalize :email from ‹" XyZ@EXAMPLE.com\\n"› to ‹"xyz@example.com"›
          but it was normalized
        ).squish

        expect(&assertion).to fail_with_message(message)
      end
    end
  end
end
