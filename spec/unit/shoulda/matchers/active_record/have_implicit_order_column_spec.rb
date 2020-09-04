require 'unit_spec_helper'

describe Shoulda::Matchers::ActiveRecord::HaveImplicitOrderColumnMatcher, type: :model do
  if active_record_supports_implicit_order_column?
    context 'when the given column exists' do
      context 'when an implicit_order_column is set on the model' do
        context 'and it matches the given column name' do
          context 'and the column name is a symbol' do
            it 'matches' do
              record = record_with_implicit_order_column_on(
                :created_at,
                class_name: 'Employee',
                columns: [:created_at],
              )

              expect { have_implicit_order_column(:created_at) }
                .to match_against(record)
                .or_fail_with(<<~MESSAGE, wrap: true)
                  Expected Employee not to have an implicit_order_column of
                  :created_at, but it did.
                MESSAGE
            end
          end

          context 'and the column name is a string' do
            it 'matches' do
              record = record_with_implicit_order_column_on(
                :created_at,
                class_name: 'Employee',
                columns: [:created_at],
              )

              expect { have_implicit_order_column('created_at') }
                .to match_against(record)
                .or_fail_with(<<~MESSAGE, wrap: true)
                  Expected Employee not to have an implicit_order_column of
                  :created_at, but it did.
                MESSAGE
            end
          end
        end

        context 'and it does not match the given column name' do
          context 'and the column name is a symbol' do
            it 'does not match, producing an appropriate message' do
              record = record_with_implicit_order_column_on(
                :created_at,
                class_name: 'Employee',
                columns: [:created_at, :email],
              )

              expect { have_implicit_order_column(:email) }
                .not_to match_against(record)
                .and_fail_with(<<-MESSAGE, wrap: true)
                  Expected Employee to have an implicit_order_column of :email,
                  but it is :created_at.
                MESSAGE
            end
          end

          context 'and the column name is a string' do
            it 'does not match, producing an appropriate message' do
              record = record_with_implicit_order_column_on(
                :created_at,
                class_name: 'Employee',
                columns: [:created_at, :email],
              )

              expect { have_implicit_order_column('email') }
                .not_to match_against(record)
                .and_fail_with(<<-MESSAGE, wrap: true)
                  Expected Employee to have an implicit_order_column of :email,
                  but it is :created_at.
                MESSAGE
            end
          end
        end
      end

      context 'when no implicit_order_column is set on the model' do
        context 'and the given column name is a symbol' do
          it 'does not match, producing an appropriate message' do
            record = record_without_implicit_order_column(
              class_name: 'Employee',
              columns: [:created_at],
            )

            expect { have_implicit_order_column(:created_at) }
              .not_to match_against(record)
              .and_fail_with(<<-MESSAGE, wrap: true)
                Expected Employee to have an implicit_order_column of
                :created_at, but implicit_order_column is not set.
              MESSAGE
          end
        end

        context 'and the given column name is a string' do
          it 'does not match, producing an appropriate message' do
            record = record_without_implicit_order_column(
              class_name: 'Employee',
              columns: [:created_at],
            )

            expect { have_implicit_order_column('created_at') }
              .not_to match_against(record)
              .and_fail_with(<<-MESSAGE, wrap: true)
                Expected Employee to have an implicit_order_column of
                :created_at, but implicit_order_column is not set.
              MESSAGE
          end
        end
      end
    end

    context 'when the given column does not exist' do
      context 'and it is a symbol' do
        it 'does not match, producing an appropriate message' do
          record = record_without_any_columns(class_name: 'Employee')

          expect { have_implicit_order_column(:whatever) }
            .not_to match_against(record)
            .and_fail_with(<<-MESSAGE, wrap: true)
              Expected Employee to have an implicit_order_column of :whatever,
              but that could not be proved: The :employees table does not have a
              :whatever column.
            MESSAGE
        end
      end

      context 'and it is a string' do
        it 'does not match, producing an appropriate message' do
          record = record_without_any_columns(class_name: 'Employee')

          expect { have_implicit_order_column('whatever') }
            .not_to match_against(record)
            .and_fail_with(<<-MESSAGE, wrap: true)
              Expected Employee to have an implicit_order_column of :whatever,
              but that could not be proved: The :employees table does not have a
              :whatever column.
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
      class_name:,
      columns: { column_name => :string }
    )
      define_model_instance(class_name, columns) do |model|
        model.implicit_order_column = column_name
      end
    end

    def record_without_implicit_order_column(class_name:, columns:)
      define_model_instance(class_name, columns)
    end

    def record_without_any_columns(class_name:)
      define_model_instance(class_name)
    end
  end
end
