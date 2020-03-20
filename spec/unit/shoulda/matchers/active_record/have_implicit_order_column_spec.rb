require 'unit_spec_helper'

describe Shoulda::Matchers::ActiveRecord::HaveImplicitOrderColumnMatcher, type: :model do
  if active_record_supports_implicit_order_column?
    context 'when the model sets implicit_order_column to the given column' do
      context 'when the given column name is a symbol' do
        it 'accepts' do
          record = record_with_implicit_order_column_on(
            :created_at,
            model_name: 'Employee',
            columns: { created_at: :timestamp },
          )

          expect { have_implicit_order_column(:created_at) }.
            to match_against(record).
            or_fail_with(<<~MESSAGE, wrap: true)
              Did not expect Employee to have an implicit_order_column of
              :created_at, but it did.
            MESSAGE
        end
      end

      context 'when the given column name is a string' do
        it 'accepts' do
          record = record_with_implicit_order_column_on(
            :created_at,
            columns: { created_at: :timestamp },
          )

          expect { have_implicit_order_column('created_at') }.
            to match_against(record).
            or_fail_with(<<~MESSAGE, wrap: true)
              Did not expect Employee to have an implicit_order_column of
              :created_at, but it did.
            MESSAGE
        end
      end
    end

    context 'when the model sets implicit_order_column to another column' do
      context 'when the given column name is a symbol' do
        it 'rejects with an appropriate failure message' do
          record = record_with_implicit_order_column_on(
            :created_at,
            columns: { created_at: :timestamp, email: :string },
          )

          expect { have_implicit_order_column(:email) }.
            not_to match_against(record).
            and_fail_with(<<~MESSAGE, wrap: true)
              Expected Employee to have an implicit_order_column of :email
              (its implicit_order_column is :created_at).
            MESSAGE
        end
      end

      context 'when the given column name is a string' do
        it 'rejects with an appropriate failure message' do
          record = record_with_implicit_order_column_on(
            :created_at,
            columns: { created_at: :timestamp, email: :string },
          )

          expect { have_implicit_order_column('email') }.
            not_to match_against(record).
            and_fail_with(<<~MESSAGE, wrap: true)
              Expected Employee to have an implicit_order_column of :email
              (its implicit_order_column is :created_at).
            MESSAGE
        end
      end
    end

    context 'when the model does NOT set implicit_order_column' do
      context 'when the given column name is a symbol' do
        it 'rejects with an appropriate failure message' do
          record = record_without_implicit_order_column(
            columns: { created_at: :timestamp },
          )

          expect { have_implicit_order_column(:created_at) }.
            not_to match_against(record).
            and_fail_with(<<~MESSAGE, wrap: true)
              Expected Employee to have an implicit_order_column of :created_at
              (it does not have an implicit_order_column).
            MESSAGE
        end
      end

      context 'when the given column name is a string' do
        it 'rejects with an appropriate failure message' do
          record = record_without_implicit_order_column(
            columns: { created_at: :timestamp },
          )

          expect { have_implicit_order_column('created_at') }.
            not_to match_against(record).
            and_fail_with(<<~MESSAGE, wrap: true)
              Expected Employee to have an implicit_order_column of :created_at
              (it does not have an implicit_order_column).
            MESSAGE
        end
      end
    end

    context 'when the given column does not exist on the table' do
      context 'when the given column name is a symbol' do
        it 'rejects with an appropriate failure message' do
          record = record_without_implicit_order_column(
            columns: { created_at: :timestamp },
          )

          expect { have_implicit_order_column(:individual) }.
            not_to match_against(record).
            and_fail_with(<<~MESSAGE, wrap: true)
              Expected Employee to have an implicit_order_column of :individual
              (employees does not have an :individual column).
            MESSAGE
        end
      end

      context 'when the given column name is a string' do
        it 'rejects with an appropriate failure message' do
          record = record_without_implicit_order_column(
            columns: { created_at: :timestamp },
          )

          expect { have_implicit_order_column('individual') }.
            not_to match_against(record).
            and_fail_with(<<~MESSAGE, wrap: true)
              Expected Employee to have an implicit_order_column of :individual
              (employees does not have an :individual column).
            MESSAGE
        end
      end
    end

    describe '#description' do
      it 'returns the correct description' do
        matcher = have_implicit_order_column(:created_at)

        expect(matcher.description).to eq(
          'have an implicit_order_column of :created_at',
        )
      end
    end

    def record_with_implicit_order_column_on(
      column_name,
      columns:,
      model_name: 'Employee'
    )
      model = define_model(model_name, columns) do |m|
        m.implicit_order_column = column_name
      end

      model.new
    end

    def record_without_implicit_order_column(columns:, model_name: 'Employee')
      define_model(model_name, columns).new
    end
  end
end
