require 'unit_spec_helper'

describe Shoulda::Matchers::ActiveRecord::HaveDbIndexMatcher, type: :model do
  describe 'the matcher' do
    shared_examples 'for when the matcher is qualified' do |
      index:,
      other_index:,
      unique:,
      qualifier_args:,
      columns: { index => :string }
    |
      if unique
        index_type = 'unique'
        inverse_description = 'not unique'
      else
        index_type = 'non-unique'
        inverse_description = 'unique'
      end

      context 'when the table has the given index' do
        context "when the index is a #{index_type} index" do
          it 'matches when used in the positive' do
            record = record_with_index_on(
              index,
              unique: unique,
              columns: columns,
            )

            expect(record).to have_db_index(index).unique(*qualifier_args)
          end

          it 'does not match when used in the negative' do
            record = record_with_index_on(
              index,
              unique: unique,
              model_name: 'Example',
              columns: columns,
            )

            assertion = lambda do
              expect(record).
                not_to have_db_index(index).
                unique(*qualifier_args)
            end

            expect(&assertion).to fail_with_message(<<-MESSAGE, wrap: true)
Expected the examples table not to have a #{index_type} index on
#{index.inspect}, but it does.
            MESSAGE
          end
        end

        context "when the index is not a #{index_type} index" do
          it 'matches when used in the negative' do
            record = record_with_index_on(
              index,
              unique: !unique,
              columns: columns,
            )

            expect(record).not_to have_db_index(index).unique(*qualifier_args)
          end

          it 'does not match when used in the positive' do
            record = record_with_index_on(
              index,
              unique: !unique,
              model_name: 'Example',
              columns: columns,
            )

            assertion = lambda do
              expect(record).to have_db_index(index).unique(*qualifier_args)
            end

            expect(&assertion).to fail_with_message(<<-MESSAGE, wrap: true)
Expected the examples table to have an index on #{index.inspect} and for it to
be #{index_type}. The index does exist, but it is #{inverse_description}.
            MESSAGE
          end
        end
      end

      context 'when the table does not have the given index' do
        it 'does not match in the positive' do
          record = record_with_index_on(
            index,
            unique: unique,
            model_name: 'Example',
            columns: columns,
          )

          assertion = lambda do
            expect(record).to have_db_index(other_index).unique(*qualifier_args)
          end

          expect(&assertion).to fail_with_message(<<-MESSAGE, wrap: true)
Expected the examples table to have a #{index_type} index on :#{other_index},
but it does not.
          MESSAGE
        end

        it 'matches in the negative' do
          expect(record_with_index_on(index, unique: unique, columns: columns)).
            not_to have_db_index(other_index).
            unique(*qualifier_args)
        end
      end
    end

    context 'assuming all models are connected to the same database' do
      context 'when given one column' do
        context 'when qualified with nothing' do
          context 'when the table has the given index' do
            it 'matches in the positive' do
              expect(record_with_index_on(:age)).to have_db_index(:age)
            end

            it 'does not match in the negative' do
              record = record_with_index_on(:age, model_name: 'Example')

              assertion = lambda do
                expect(record).not_to have_db_index(:age)
              end

              expect(&assertion).to fail_with_message(<<-MESSAGE)
Expected the examples table not to have an index on :age, but it does.
              MESSAGE
            end
          end

          context 'when the table does not have the given index' do
            it 'does not match in the positive' do
              assertion = lambda do
                record = record_with_index_on(:age, model_name: 'Example')
                expect(record).to have_db_index(:name)
              end

              expect(&assertion).to fail_with_message(<<-MESSAGE)
Expected the examples table to have an index on :name, but it does not.
              MESSAGE
            end

            it 'matches in the negative' do
              expect(record_with_index_on(:age)).not_to have_db_index(:name)
            end
          end
        end

        context 'when qualified with unique' do
          include_examples(
            'for when the matcher is qualified',
            index: :ssn,
            other_index: :name,
            unique: true,
            qualifier_args: [],
          )

          context 'when there are multiple possible matching columns' do
            let(:model) do
              define_model(
                'Employee',
                { ssn: :string },
                parent_class: DevelopmentRecord,
                customize_table: -> (table) {
                  table.index(:ssn, name: 'aaa', unique: false)
                  table.index(:ssn, name: 'bbb', unique: true)
                  table.index(:ssn, name: 'ccc', unique: false)
                },
              )
            end

            it 'matches in the positive' do
              expect(model.new).to have_db_index(:ssn).unique
            end

            it 'does not match in the negative' do
              assertion = lambda do
                expect(model.new).not_to have_db_index(:ssn).unique
              end

              expect(&assertion).to fail_with_message(<<-MESSAGE)
Expected the employees table not to have a unique index on :ssn, but it
does.
              MESSAGE
            end
          end
        end

        context 'when qualified with unique: true' do
          include_examples(
            'for when the matcher is qualified',
            index: :ssn,
            other_index: :name,
            unique: true,
            qualifier_args: [true],
          )
        end

        context 'when qualified with unique: false' do
          include_examples(
            'for when the matcher is qualified',
            index: :ssn,
            other_index: :name,
            unique: false,
            qualifier_args: [false],
          )
        end
      end

      context 'when given a group of columns' do
        context 'when the table has the given index' do
          it 'matches when used in the positive' do
            record = record_with_index_on(
              [:geocodable_id, :geocodable_type],
              columns: { geocodable_id: :integer, geocodable_type: :string },
            )
            expect(record).to have_db_index([:geocodable_id, :geocodable_type])
          end

          it 'does not match when used in the negative' do
            record = record_with_index_on(
              [:geocodable_id, :geocodable_type],
              model_name: 'Example',
              columns: { geocodable_id: :integer, geocodable_type: :string },
            )

            assertion = lambda do
              expect(record).not_to have_db_index(
                [:geocodable_id, :geocodable_type],
              )
            end

            expect(&assertion).to fail_with_message(<<-MESSAGE)
Expected the examples table not to have an index on [:geocodable_id,
:geocodable_type], but it does.
            MESSAGE
          end
        end

        context 'when the table does not have the given index' do
          it 'does not match when used in the positive' do
            record = record_with_index_on(:age, model_name: 'Example')

            assertion = lambda do
              expect(record).to have_db_index(
                [:geocodable_id, :geocodable_type],
              )
            end

            expect(&assertion).to fail_with_message(<<-MESSAGE)
Expected the examples table to have an index on [:geocodable_id,
:geocodable_type], but it does not.
            MESSAGE
          end

          it 'matches when used in the negative' do
            record = record_with_index_on(:age)

            expect(record).not_to have_db_index(
              [:geocodable_id, :geocodable_type],
            )
          end
        end
      end

      if database_supports_expression_indexes?
        context 'when given an expression' do
          context 'qualified with nothing' do
            context 'when the table has the given index' do
              it 'matches when used in the positive' do
                record = record_with_index_on(
                  'lower((code)::text)',
                  columns: { code: :string },
                )
                expect(record).to have_db_index('lower((code)::text)')
              end

              it 'does not match when used in the negative' do
                record = record_with_index_on(
                  'lower((code)::text)',
                  model_name: 'Example',
                  columns: { code: :string },
                )

                assertion = lambda do
                  expect(record).not_to have_db_index('lower((code)::text)')
                end

                expect(&assertion).to fail_with_message(<<-MESSAGE, wrap: true)
Expected the examples table not to have an index on "lower((code)::text)", but
it does.
                MESSAGE
              end
            end

            context 'when the table does not have the given index' do
              it 'matches when used in the negative' do
                record = record_with_index_on(
                  'code',
                  columns: { code: :string },
                )
                expect(record).not_to have_db_index('lower((code)::text)')
              end

              it 'does not match when used in the positive' do
                record = record_with_index_on(
                  'code',
                  model_name: 'Example',
                  columns: { code: :string },
                )

                assertion = lambda do
                  expect(record).to have_db_index('lower((code)::text)')
                end

                expect(&assertion).to fail_with_message(<<-MESSAGE, wrap: true)
Expected the examples table to have an index on "lower((code)::text)", but it
does not.
                MESSAGE
              end
            end
          end

          context 'when qualified with unique' do
            include_examples(
              'for when the matcher is qualified',
              index: 'lower((code)::text)',
              other_index: 'code',
              columns: { code: :string },
              unique: true,
              qualifier_args: [],
            )
          end

          context 'when qualified with unique: true' do
            include_examples(
              'for when the matcher is qualified',
              index: 'lower((code)::text)',
              other_index: 'code',
              columns: { code: :string },
              unique: true,
              qualifier_args: [true],
            )
          end

          context 'when qualified with unique: false' do
            include_examples(
              'for when the matcher is qualified',
              index: 'lower((code)::text)',
              other_index: 'code',
              columns: { code: :string },
              unique: false,
              qualifier_args: [false],
            )
          end
        end
      end
    end

    context 'when not all models are connected to the same database' do
      context 'when the table has the given index' do
        it 'matches' do
          record_connected_to_development = record_with_index_on(
            :age1,
            model_name: 'DevelopmentEmployee',
            parent_class: DevelopmentRecord,
          )
          record_connected_to_production = record_with_index_on(
            :age2,
            model_name: 'ProductionEmployee',
            parent_class: ProductionRecord,
          )

          expect(record_connected_to_development).to have_db_index(:age1)
          expect(record_connected_to_production).to have_db_index(:age2)
        end
      end
    end
  end

  describe '#description' do
    shared_examples 'for when the matcher is qualified' do |index:, index_type:, qualifier_args:|
      it 'returns the correct description' do
        matcher = have_db_index(index).unique(*qualifier_args)

        expect(matcher.description).to eq(
          "have a #{index_type} index on #{index.inspect}",
        )
      end
    end

    context 'when given one column' do
      context 'when not qualified with anything' do
        it 'returns the correct description' do
          matcher = have_db_index(:age)
          expect(matcher.description).to eq('have an index on :age')
        end
      end

      context 'when qualified with unique' do
        include_examples(
          'for when the matcher is qualified',
          index: :age,
          index_type: 'unique',
          qualifier_args: [],
        )
      end

      context 'when qualified with unique: true' do
        include_examples(
          'for when the matcher is qualified',
          index: :age,
          index_type: 'unique',
          qualifier_args: [true],
        )
      end

      context 'when qualified with unique: false' do
        include_examples(
          'for when the matcher is qualified',
          index: :age,
          index_type: 'non-unique',
          qualifier_args: [false],
        )
      end
    end

    context 'when given a group of columns' do
      context 'when not qualified with anything' do
        it 'returns the correct description' do
          matcher = have_db_index([:user_id, :post_id])
          expect(matcher.description).to eq(
            'have an index on [:user_id, :post_id]',
          )
        end
      end

      context 'when qualified with unique' do
        include_examples(
          'for when the matcher is qualified',
          index: [:geocodable_type, :geocodable_id],
          index_type: 'unique',
          qualifier_args: [],
        )
      end

      context 'when qualified with unique: true' do
        include_examples(
          'for when the matcher is qualified',
          index: [:geocodable_type, :geocodable_id],
          index_type: 'unique',
          qualifier_args: [true],
        )
      end

      context 'when qualified with unique: false' do
        include_examples(
          'for when the matcher is qualified',
          index: [:geocodable_type, :geocodable_id],
          index_type: 'non-unique',
          qualifier_args: [false],
        )
      end
    end

    if database_supports_expression_indexes?
      context 'when given an expression' do
        context 'when not qualified with anything' do
          it 'returns the correct description' do
            matcher = have_db_index('lower(code)')
            expect(matcher.description).to eq('have an index on "lower(code)"')
          end
        end

        context 'when qualified with unique' do
          include_examples(
            'for when the matcher is qualified',
            index: 'lower(code)',
            index_type: 'unique',
            qualifier_args: [],
          )
        end

        context 'when qualified with unique: true' do
          include_examples(
            'for when the matcher is qualified',
            index: 'lower(code)',
            index_type: 'unique',
            qualifier_args: [true],
          )
        end

        context 'when qualified with unique: false' do
          include_examples(
            'for when the matcher is qualified',
            index: 'lower(code)',
            index_type: 'non-unique',
            qualifier_args: [false],
          )
        end
      end
    end
  end

  def record_with_index_on(
    column_name_or_names,
    model_name: 'Employee',
    parent_class: DevelopmentRecord,
    columns: nil,
    **index_options
  )
    columns ||= Array.wrap(column_name_or_names).inject({}) do |hash, name|
      hash.merge!(name => :string)
    end

    model = define_model(
      model_name,
      columns,
      parent_class: parent_class,
      customize_table: -> (table) {
        table.index(column_name_or_names, **index_options)
      },
    )
    model.new
  end
end
