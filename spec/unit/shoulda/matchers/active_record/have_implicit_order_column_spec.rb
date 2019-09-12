require 'unit_spec_helper'

describe Shoulda::Matchers::ActiveRecord::HaveImplicitOrderColumnMatcher, type: :model do
  if active_record_supports_implicit_order_column?
    context 'when implicit_order_column is defined for the column' do
      context 'when column name is a symbol' do
        it 'accepts' do
          record = record_with_implicit_order_column_on(
            'created_at',
            columns: { created_at: :timestamp },
          )

          expect(record).to have_implicit_order_column(:created_at)
        end
      end

      context 'when column name is a string' do
        it 'accepts' do
          record = record_with_implicit_order_column_on(
            'created_at',
            columns: { created_at: :timestamp },
          )

          expect(record).to have_implicit_order_column('created_at')
        end
      end
    end

    context 'when implicit_order_column is defined for another column' do
      context 'when column name is a symbol' do
        it 'rejects with an appropriate failure message' do
          record = record_with_implicit_order_column_on(
            'created_at',
            columns: { created_at: :timestamp, email: :string },
          )

          assertion = lambda {
            expect(record).to have_implicit_order_column(:email)
          }

          message = format_message(<<-MESSAGE, one_line: true)
            Expected Employee to have implicit_order_column set to email
            (Employee implicit_order_column is set to created_at)
          MESSAGE

          expect(&assertion).to fail_with_message(message)
        end
      end

      context 'when column name is a string' do
        it 'rejects with an appropriate failure message' do
          record = record_with_implicit_order_column_on(
            'created_at',
            columns: { created_at: :timestamp, email: :string },
          )

          assertion = lambda {
            expect(record).to have_implicit_order_column('email')
          }

          message = format_message(<<-MESSAGE, one_line: true)
            Expected Employee to have implicit_order_column set to email
            (Employee implicit_order_column is set to created_at)
          MESSAGE

          expect(&assertion).to fail_with_message(message)
        end
      end
    end

    context 'when implicit_order_column is NOT defined on model' do
      context 'when column name is a symbol' do
        it 'rejects with an appropriate failure message' do
          record = record_without_implicit_order_column(
            columns: { created_at: :timestamp },
          )

          assertion = lambda {
            expect(record).to have_implicit_order_column(:created_at)
          }

          message = format_message(<<-MESSAGE, one_line: true)
            Expected Employee to have implicit_order_column set to created_at
            (Employee implicit_order_column is not set)
          MESSAGE

          expect(&assertion).to fail_with_message(message)
        end
      end

      context 'when column name is a string' do
        it 'rejects with an appropriate failure message' do
          record = record_without_implicit_order_column(
            columns: { created_at: :timestamp },
          )

          assertion = lambda {
            expect(record).to have_implicit_order_column('created_at')
          }

          message = format_message(<<-MESSAGE, one_line: true)
            Expected Employee to have implicit_order_column set to created_at
            (Employee implicit_order_column is not set)
          MESSAGE

          expect(&assertion).to fail_with_message(message)
        end
      end
    end

    context 'when given column does NOT exist' do
      context 'when column name is a symbol' do
        it 'rejects with an appropriate failure message' do
          record = record_without_implicit_order_column(
            columns: { created_at: :timestamp },
          )

          assertion = lambda {
            expect(record).to have_implicit_order_column(:whatever)
          }

          message = format_message(<<-MESSAGE, one_line: true)
            Expected Employee to have implicit_order_column set to whatever
            (Employee does not have a db column named whatever)
          MESSAGE

          expect(&assertion).to fail_with_message(message)
        end
      end

      context 'when column name is a string' do
        it 'rejects with an appropriate failure message' do
          record = record_without_implicit_order_column(
            columns: { created_at: :timestamp },
          )

          assertion = lambda {
            expect(record).to have_implicit_order_column('whatever')
          }

          message = format_message(<<-MESSAGE, one_line: true)
            Expected Employee to have implicit_order_column set to whatever
            (Employee does not have a db column named whatever)
          MESSAGE

          expect(&assertion).to fail_with_message(message)
        end
      end
    end

    describe 'description' do
      it 'returns correct description' do
        matcher = have_implicit_order_column(:created_at)

        expect(matcher.description).to \
          eq('have implicit_order_column assigned to created_at')
      end
    end

    def record_with_implicit_order_column_on(column_name, columns:)
      define_model(:employee, columns) do |model|
        model.implicit_order_column = column_name
      end.new
    end

    def record_without_implicit_order_column(columns:)
      define_model(:employee, columns).new
    end
  end
end
