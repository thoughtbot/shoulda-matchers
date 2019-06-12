require 'unit_spec_helper'

describe(
  Shoulda::Matchers::ActiveRecord::AssociationMatcher, 'belong_to',
  type: :model,
) do
  include UnitTests::ApplicationConfigurationHelpers

  context 'qualified with nothing' do
    context 'when the association exists on the model' do
      context 'and it is a belongs_to' do
        context 'and it is polymorphic' do
          it 'matches' do
            record = record_belonging_to(
              :parent,
              model_name: 'Child',
              extra_columns: { parent_type: :string },
              polymorphic: true,
            )

            expect { belong_to(:parent) }.
              to match_against(record).
              or_fail_with(<<~MESSAGE, unwrap: true)
                Did not expect Child to have a belongs_to association called
                parent
              MESSAGE
          end
        end

        context 'and it has not been configured with a custom foreign_key' do
          context 'and the default foreign key exists on the table' do
            it 'matches' do
              record = record_belonging_to(:parent, model_name: 'Child')

              expect { belong_to(:parent) }.
                to match_against(record).
                or_fail_with(<<~MESSAGE, unwrap: true)
                  Did not expect Child to have a belongs_to association called
                  parent
                MESSAGE
            end
          end

          context 'but the default foreign key does not exist on the table' do
            it 'does not match' do
              define_model 'Parent'
              child_model = define_model('Child') { belongs_to :parent }

              expect { belong_to(:parent) }.
                not_to match_against(child_model.new).
                and_fail_with(<<~MESSAGE, unwrap: true)
                  Expected Child to have a belongs_to association called parent
                  (Child does not have a parent_id foreign key.)
                MESSAGE
            end
          end
        end

        context 'and it has been configured with a custom foreign_key' do
          it 'matches' do
            record = record_belonging_to(
              :parent,
              model_name: 'Child',
              column_name: 'guardian_id',
              foreign_key: 'guardian_id',
            )

            expect { belong_to(:parent) }.
              to match_against(record).
              or_fail_with(<<~MESSAGE, unwrap: true)
                Did not expect Child to have a belongs_to association called
                parent
              MESSAGE
          end
        end

        context 'and the implicit class it refers to does not exist' do
          it 'does not match' do
            record = define_model('Child') { belongs_to :parent }.new

            expect { belong_to(:parent) }.
              not_to match_against(record).
              and_fail_with(<<~MESSAGE, unwrap: true)
                Expected Child to have a belongs_to association called parent
                (Parent does not exist)
              MESSAGE
          end
        end

        context 'and the explicit class it refers to does not exist' do
          it 'does not match' do
            record = define_model('Child') do
              belongs_to :parent, class_name: 'TreeParent'
            end.new

            expect { belong_to(:parent) }.
              not_to match_against(record).
              and_fail_with(<<~MESSAGE, unwrap: true)
                Expected Child to have a belongs_to association called parent
                (TreeParent does not exist)
              MESSAGE
          end
        end

        context 'and it is configured with validate: true' do
          it 'matches anyway' do
            record = record_belonging_to(
              :parent,
              model_name: 'Child',
              validate: true,
            )

            expect { belong_to(:parent) }.
              to match_against(record).
              or_fail_with(<<~MESSAGE, unwrap: true)
                Did not expect Child to have a belongs_to association called
                parent
              MESSAGE
          end
        end

        context 'and it is configured with validate: false' do
          it 'matches anyway' do
            record = record_belonging_to(
              :parent,
              model_name: 'Child',
              validate: false,
            )

            expect { belong_to(:parent) }.
              to match_against(record).
              or_fail_with(<<~MESSAGE, unwrap: true)
                Did not expect Child to have a belongs_to association called
                parent
              MESSAGE
          end
        end

        if active_record_supports_optional_for_associations?
          context 'when the association has been configured with neither optional nor required' do
            context 'when belongs_to is configured to be required by default' do
              context 'when the model does not manually ensure the association is set' do
                it 'matches' do
                  with_belongs_to_as_required_by_default do
                    record = record_belonging_to(:parent, model_name: 'Child')

                    expect { belong_to(:parent) }.
                      to match_against(record).
                      or_fail_with(<<~MESSAGE, unwrap: true)
                        Did not expect Child to have a belongs_to association
                        called parent
                      MESSAGE
                  end
                end
              end

              context 'when the model manually ensures that the association is set' do
                it 'does not match' do
                  with_belongs_to_as_required_by_default do
                    record =
                      record_belonging_to(:parent, model_name: 'Child') do
                        before_validation :ensure_parent_is_set

                        def ensure_parent_is_set
                          self.parent = Parent.create
                        end
                      end

                    expect { belong_to(:parent) }.
                      not_to match_against(record).
                      and_fail_with(<<~MESSAGE, unwrap: true)
                        Expected Child to have a belongs_to association called
                        parent (and for the record to fail validation if :parent
                        is unset; i.e., either the association should have been
                        defined with `required: true`, or there should be a
                        presence validation on :parent)
                      MESSAGE
                  end
                end
              end
            end

            context 'when belongs_to is not configured to be required by default' do
              context 'and a presence validation is on the attribute instead of using required: true' do
                it 'matches' do
                  with_belongs_to_as_optional_by_default do
                    record =
                      record_belonging_to(:parent, model_name: 'Child') do
                        validates_presence_of :parent
                      end

                    expect { belong_to(:parent) }.
                      to match_against(record).
                      or_fail_with(<<~MESSAGE, unwrap: true)
                        Did not expect Child to have a belongs_to association
                        called parent
                      MESSAGE
                  end
                end
              end

              context 'and a presence validation is on the attribute with a condition' do
                context 'and the condition is true' do
                  it 'matches' do
                    with_belongs_to_as_optional_by_default do
                      model =
                        model_belonging_to(:parent, model_name: 'Child') do
                          attr_accessor :condition
                          validates_presence_of :parent, if: :condition
                        end

                      record = model.new(condition: true)

                      expect { belong_to(:parent) }.
                        to match_against(record).
                        or_fail_with(<<~MESSAGE, unwrap: true)
                          Did not expect Child to have a belongs_to association
                          called parent
                        MESSAGE
                    end
                  end
                end

                context 'and the condition is false' do
                  it 'matches' do
                    with_belongs_to_as_optional_by_default do
                      model =
                        model_belonging_to(:parent, model_name: 'Child') do
                          attr_accessor :condition
                          validates_presence_of :parent, if: :condition
                        end

                      record = model.new(condition: false)

                      expect { belong_to(:parent) }.
                        to match_against(record).
                        or_fail_with(<<~MESSAGE, unwrap: true)
                          Did not expect Child to have a belongs_to association
                          called parent
                        MESSAGE
                    end
                  end
                end
              end

              context 'and there is no explicit presence validation on the attribute' do
                it 'matches' do
                  with_belongs_to_as_optional_by_default do
                    record = record_belonging_to(:parent, model_name: 'Child')

                    expect { belong_to(:parent) }.
                      to match_against(record).
                      or_fail_with(<<~MESSAGE, unwrap: true)
                        Did not expect Child to have a belongs_to association
                        called parent
                      MESSAGE
                  end
                end
              end
            end
          end

          context 'when the association has been configured with optional: true' do
            it 'does not match' do
              record = record_belonging_to(
                :parent,
                model_name: 'Child',
                optional: true,
              )

              expect { belong_to(:parent) }.
                not_to match_against(record).
                and_fail_with(<<~MESSAGE, unwrap: true)
                  Expected Child to have a belongs_to association called parent
                  (and for the record to fail validation if :parent is unset;
                  i.e., either the association should have been defined with
                  `required: true`, or there should be a presence validation on
                  :parent)
                MESSAGE
            end
          end
        else
          context 'and a presence validation is on the attribute instead of using required: true' do
            it 'matches' do
              record = record_belonging_to(:parent) do
                validates_presence_of :parent
              end

              expect { belong_to(:parent) }.
                to match_against(record).
                or_fail_with(<<~MESSAGE, unwrap: true)
                  Did not expect Child to have a belongs_to association
                  called parent
                MESSAGE
            end
          end

          context 'and a presence validation is on the attribute with a condition' do
            context 'and the condition is true' do
              it 'matches' do
                model = model_belonging_to(:parent) do
                  attr_accessor :condition
                  validates_presence_of :parent, if: :condition
                end

                record = model.new(condition: true)

                expect { belong_to(:parent) }.
                  to match_against(record).
                  or_fail_with(<<~MESSAGE, unwrap: true)
                    Did not expect Child to have a belongs_to association
                    called parent
                  MESSAGE
              end
            end

            context 'and the condition is false' do
              it 'matches' do
                model = model_belonging_to(:parent) do
                  attr_accessor :condition
                  validates_presence_of :parent, if: :condition
                end

                record = model.new(condition: false)

                expect { belong_to(:parent) }.
                  to match_against(record).
                  or_fail_with(<<~MESSAGE, unwrap: true)
                    Did not expect Child to have a belongs_to association
                    called parent
                  MESSAGE
              end
            end
          end

          context 'and there is no explicit presence validation on the attribute' do
            it 'matches' do
              record = record_belonging_to(:parent)

              expect { belong_to(:parent) }.
                to match_against(record).
                or_fail_with(<<~MESSAGE, unwrap: true)
                  Did not expect Child to have a belongs_to association
                  called parent
                MESSAGE
            end
          end
        end

        context 'when the association has been configured with required: true' do
          it 'matches' do
            record = record_belonging_to(
              :parent,
              model_name: 'Child',
              required: true,
            )

            expect { belong_to(:parent) }.
              to match_against(record).
              or_fail_with(<<~MESSAGE, unwrap: true)
                Did not expect Child to have a belongs_to association called
                parent
              MESSAGE
          end
        end
      end

      context 'and it is not a belongs_to' do
        it 'does not match' do
          define_model 'Parent', child_id: :integer
          child_model = define_model('Child') { has_one :parent }

          expect { belong_to(:parent) }.
            not_to match_against(child_model.new).
            and_fail_with(<<~MESSAGE, unwrap: true)
              Expected Child to have a belongs_to association called parent
              (actual association type was has_one)
            MESSAGE
        end
      end
    end

    context 'when the association does not exist on the model' do
      it 'does not match' do
        expect { belong_to(:parent) }.
          not_to match_against(define_model('Child').new).
          and_fail_with(<<~MESSAGE, unwrap: true)
            Expected Child to have a belongs_to association called parent (no
            association called parent)
          MESSAGE
      end
    end
  end

  context 'qualified with with_primary_key' do
    context 'when the association has been configured with the same custom primary key' do
      it 'matches' do
        record = record_belonging_to(
          :parent,
          model_name: 'Child',
          extra_columns: { custom_primary_key: :integer },
          primary_key: 'custom_primary_key',
        )

        expect { belong_to(:parent).with_primary_key(:custom_primary_key) }.
          to match_against(record).
          or_fail_with(<<~MESSAGE, unwrap: true)
            Did not expect Child to have a belongs_to association called parent
          MESSAGE
      end
    end

    context 'when the association has been configured with a different custom primary key' do
      it 'does not match' do
        record = record_belonging_to(
          :parent,
          model_name: 'Child',
          extra_columns: { different_primary_key: :integer },
          primary_key: :different_primary_key,
        )

        expect { belong_to(:parent).with_primary_key(:custom_primary_key) }.
          not_to match_against(record).
          and_fail_with(<<~MESSAGE, unwrap: true)
            Expected Child to have a belongs_to association called parent (Child
            does not have a custom_primary_key primary key)
          MESSAGE
      end
    end

    context 'when the association has not been configured with a custom primary key at all' do
      it 'does not match' do
        record = record_belonging_to(:parent, model_name: 'Child')

        expect { belong_to(:parent).with_primary_key(:custom_primary_key) }.
          not_to match_against(record).
          and_fail_with(<<~MESSAGE, unwrap: true)
            Expected Child to have a belongs_to association called parent (Child
            does not have a custom_primary_key primary key)
          MESSAGE
      end
    end
  end

  context 'qualified with dependent' do
    context 'when the association has been configured with the same value for :dependent' do
      it 'matches' do
        record = record_belonging_to(
          :parent,
          model_name: 'Child',
          dependent: :destroy,
        )

        expect { belong_to(:parent).dependent(:destroy) }.
          to match_against(record).
          or_fail_with(<<~MESSAGE, unwrap: true)
            Did not expect Child to have a belongs_to association called parent
          MESSAGE
      end
    end

    context 'when the association has been configured with a different value for :dependent' do
      it 'does not match' do
        record = record_belonging_to(
          :parent,
          model_name: 'Child',
          dependent: :delete,
        )

        expect { belong_to(:parent).dependent(:destroy) }.
          not_to match_against(record).
          and_fail_with(<<~MESSAGE, unwrap: true)
            Expected Child to have a belongs_to association called parent
            (parent should have destroy dependency)
          MESSAGE
      end
    end

    context 'when the association has not been configured with :dependent at all' do
      it 'does not match' do
        record = record_belonging_to(:parent, model_name: 'Child')

        expect { belong_to(:parent).dependent(:destroy) }.
          not_to match_against(record).
          and_fail_with(<<~MESSAGE, unwrap: true)
            Expected Child to have a belongs_to association called parent
            (parent should have destroy dependency)
          MESSAGE
      end
    end
  end

  context 'qualified with counter_cache' do
    context 'when the association has been configured with counter_cache: true' do
      it 'matches' do
        record = record_belonging_to(
          :parent,
          model_name: 'Child',
          counter_cache: true,
        )

        expect { belong_to(:parent).counter_cache }.
          to match_against(record).
          or_fail_with(<<~MESSAGE, unwrap: true)
            Did not expect Child to have a belongs_to association called parent
          MESSAGE
      end
    end

    context 'when the association has been configured with counter_cache: false' do
      it 'does not match' do
        record = record_belonging_to(
          :parent,
          model_name: 'Child',
          counter_cache: false,
        )

        expect { belong_to(:parent).counter_cache }.
          not_to match_against(record).
          and_fail_with(<<~MESSAGE, unwrap: true)
            Expected Child to have a belongs_to association called parent
            (parent should have counter_cache => true)
          MESSAGE
      end
    end

    context 'when the association has not been configured with :counter_cache at all' do
      it 'does not match' do
        record = record_belonging_to(:parent, model_name: 'Child')

        expect { belong_to(:parent).counter_cache }.
          not_to match_against(record).
          and_fail_with(<<~MESSAGE, unwrap: true)
            Expected Child to have a belongs_to association called parent
            (parent should have counter_cache => true)
          MESSAGE
      end
    end
  end

  context 'qualified with counter_cache(true)' do
    context 'when the association has been configured with counter_cache: true' do
      it 'matches' do
        record = record_belonging_to(
          :parent,
          model_name: 'Child',
          counter_cache: true,
        )

        expect { belong_to(:parent).counter_cache(true) }.
          to match_against(record).
          or_fail_with(<<~MESSAGE, unwrap: true)
            Did not expect Child to have a belongs_to association called parent
          MESSAGE
      end
    end

    context 'when the association has been configured with counter_cache: false' do
      it 'does not match' do
        record = record_belonging_to(
          :parent,
          model_name: 'Child',
          counter_cache: false,
        )

        expect { belong_to(:parent).counter_cache(true) }.
          not_to match_against(record).
          and_fail_with(<<~MESSAGE, unwrap: true)
            Expected Child to have a belongs_to association called parent
            (parent should have counter_cache => true)
          MESSAGE
      end
    end

    context 'when the association has not been configured with :counter_cache at all' do
      it 'does not match' do
        record = record_belonging_to(:parent, model_name: 'Child')

        expect { belong_to(:parent).counter_cache(true) }.
          not_to match_against(record).
          and_fail_with(<<~MESSAGE, unwrap: true)
            Expected Child to have a belongs_to association called parent
            (parent should have counter_cache => true)
          MESSAGE
      end
    end
  end

  context 'qualified with counter_cache(false)' do
    context 'when the association has been configured with counter_cache: true' do
      it 'does not match' do
        record = record_belonging_to(
          :parent,
          model_name: 'Child',
          counter_cache: true,
        )

        expect { belong_to(:parent).counter_cache(false) }.
          not_to match_against(record).
          and_fail_with(<<~MESSAGE, unwrap: true)
            Expected Child to have a belongs_to association called parent
            (parent should have counter_cache => false)
          MESSAGE
      end
    end

    context 'when the association has been configured with counter_cache: false' do
      it 'matches' do
        record = record_belonging_to(
          :parent,
          model_name: 'Child',
          counter_cache: false,
        )

        expect { belong_to(:parent).counter_cache(false) }.
          to match_against(record).
          or_fail_with(<<~MESSAGE, unwrap: true)
            Did not expect Child to have a belongs_to association called parent
          MESSAGE
      end
    end

    context 'when the association has not been configured with :counter_cache at all' do
      # TODO: This should match
      it 'does not match' do
        record = record_belonging_to(:parent, model_name: 'Child')

        expect { belong_to(:parent).counter_cache(false) }.
          not_to match_against(record).
          and_fail_with(<<~MESSAGE, unwrap: true)
            Expected Child to have a belongs_to association called parent
            (parent should have counter_cache => false)
          MESSAGE
      end
    end
  end

  context 'qualified with inverse_of' do
    context 'when the parent model has the inverse association' do
      context 'when the association has been configured with the same value for :inverse_of' do
        it 'matches' do
          record = record_belonging_to(
            :parent,
            model_name: 'Child',
            inverse_of: :children,
            include_has_many: true,
          )

          expect { belong_to(:parent).inverse_of(:children) }.
            to match_against(record).
            or_fail_with(<<~MESSAGE, unwrap: true)
              Did not expect Child to have a belongs_to association called
              parent
            MESSAGE
        end
      end

      context 'when the association has been configured with a different value for :inverse_of' do
        it 'does not match' do
          record = record_belonging_to(
            :parent,
            model_name: 'Child',
            inverse_of: :something_else,
            include_has_many: true,
          )

          expect { belong_to(:parent).inverse_of(:children) }.
            not_to match_against(record).
            and_fail_with(<<~MESSAGE, unwrap: true)
              Expected Child to have a belongs_to association called parent
              (parent should have inverse_of => children)
            MESSAGE
        end
      end

      context 'when the association has not been configured with :inverse_of at all' do
        it 'does not match' do
          record = record_belonging_to(:parent, model_name: 'Child')

          expect { belong_to(:parent).inverse_of(:children) }.
            not_to match_against(record).
            and_fail_with(<<~MESSAGE, unwrap: true)
              Expected Child to have a belongs_to association called parent
              (parent should have inverse_of => children)
            MESSAGE
        end
      end
    end

    context 'when the parent model does not have the inverse association' do
      it 'fails' do
        pending "This won't work"

        record = record_belonging_to(:parent, model_name: 'Child')

        expect { belong_to(:parent).inverse_of(:children) }.
          not_to match_against(record).
          and_fail_with(<<~MESSAGE, unwrap: true)
            Expected Child to have a belongs_to association called parent
            (Parent does not have an association :children)
          MESSAGE
      end
    end
  end

  context 'qualified with conditions' do
    context 'when the association has been configured with the same set of conditions' do
      it 'matches' do
        record = record_belonging_to(
          :parent,
          model_name: 'Child',
          scope: -> { where(adopter: true) },
        )

        expect { belong_to(:parent).conditions(adopter: true) }.
          to match_against(record).
          or_fail_with(<<~MESSAGE, unwrap: true)
            Did not expect Child to have a belongs_to association called parent
          MESSAGE
      end
    end

    context 'when the association has been configured with a different set of conditions' do
      it 'does not match' do
        record = record_belonging_to(
          :parent,
          model_name: 'Child',
          scope: -> { where(biological: true) },
        )

        expect { belong_to(:parent).conditions(adopter: true) }.
          not_to match_against(record).
          and_fail_with(<<~MESSAGE, unwrap: true)
            Expected Child to have a belongs_to association called parent
            (parent should have the following conditions: {:adopter=>true})
          MESSAGE
      end
    end

    context 'when the association has not been configured with any conditions' do
      it 'does not match' do
        record = record_belonging_to(:parent, model_name: 'Child')

        expect { belong_to(:parent).conditions(adopter: true) }.
          not_to match_against(record).
          and_fail_with(<<~MESSAGE, unwrap: true)
            Expected Child to have a belongs_to association called parent
            (parent should have the following conditions: {:adopter=>true})
          MESSAGE
      end
    end
  end

  context 'qualified with class_name' do
    context 'when the association has been configured with an explicit class_name' do
      context 'which refers to a real class' do
        context 'and is the same as the given class_name' do
          context 'and the class is not namespaced' do
            it 'matches' do
              define_class('TreeParent')
              record = record_belonging_to(
                :parent,
                model_name: 'Child',
                class_name: 'TreeParent',
              )

              expect { belong_to(:parent).class_name('TreeParent') }.
                to match_against(record).
                or_fail_with(<<~MESSAGE, unwrap: true)
                  Did not expect Child to have a belongs_to association called
                  parent
                MESSAGE
            end
          end

          context 'and the class is namespaced' do
            it 'matches' do
              define_module('Models')
              define_model('Models::Organization')
              record = record_belonging_to(
                :organization,
                model_name: 'Models::User',
                class_name: 'Organization',
              )

              expect { belong_to(:organization).class_name('Organization') }.
                to match_against(record).
                or_fail_with(<<~MESSAGE, unwrap: true)
                  Did not expect Models::User to have a belongs_to association
                  called organization
                MESSAGE
            end
          end

          context 'and the class is both in the global namespace and in a sub-namespace' do
            it 'resolves the class inside the sub-namespace' do
              define_module('Models')
              define_module('Organization')
              define_model('Models::Organization')
              record = record_belonging_to(
                :organization,
                model_name: 'Models::User',
                class_name: 'Organization',
              )

              expect { belong_to(:organization).class_name('Organization') }.
                to match_against(record).
                or_fail_with(<<~MESSAGE, unwrap: true)
                  Did not expect Models::User to have a belongs_to association
                  called organization
                MESSAGE
            end
          end
        end

        context 'but is different than the given class_name' do
          context 'which refers to a real class' do
            it 'does not match' do
              define_class('HumanParent')
              define_class('TreeParent')
              record = record_belonging_to(
                :parent,
                model_name: 'Child',
                class_name: 'HumanParent',
              )

              expect { belong_to(:parent).class_name('TreeParent') }.
                not_to match_against(record).
                and_fail_with(<<~MESSAGE, unwrap: true)
                  Expected Child to have a belongs_to association called parent
                  (parent should resolve to TreeParent for class_name)
                MESSAGE
            end
          end

          context 'which does not refer to a real class' do
            it 'does not match' do
              define_class('HumanParent')
              record = record_belonging_to(
                :parent,
                model_name: 'Child',
                class_name: 'HumanParent',
              )

              expect { belong_to(:parent).class_name('TreeParent') }.
                not_to match_against(record).
                and_fail_with(<<~MESSAGE, unwrap: true)
                  Expected Child to have a belongs_to association called parent
                  (parent should resolve to TreeParent for class_name)
                MESSAGE
            end
          end
        end
      end
    end

    context 'when the association has not been configured with an explicit class name' do
      context "and the given class_name matches the association's default class_name" do
        it 'matches' do
          record = record_belonging_to(:parent, model_name: 'Child')

          expect { belong_to(:parent).class_name('Parent') }.
            to match_against(record).
            or_fail_with(<<~MESSAGE, unwrap: true)
              Did not expect Child to have a belongs_to association called
              parent
            MESSAGE
        end
      end

      context "and the given class_name does not match the association's default class_name" do
        context 'but refers to a real class' do
          it 'does not match' do
            define_class('TreeParent')
            record = record_belonging_to(:parent, model_name: 'Child')

            expect { belong_to(:parent).class_name('TreeParent') }.
              not_to match_against(record).
              and_fail_with(<<~MESSAGE, unwrap: true)
                Expected Child to have a belongs_to association called parent
                (parent should resolve to TreeParent for class_name)
              MESSAGE
          end
        end

        context 'and it does not refer to a real class' do
          it 'does not match' do
            record = record_belonging_to(:parent, model_name: 'Child')

            expect { belong_to(:parent).class_name('TreeParent') }.
              not_to match_against(record).
              and_fail_with(<<~MESSAGE, unwrap: true)
                Expected Child to have a belongs_to association called parent
                (parent should resolve to TreeParent for class_name)
              MESSAGE
          end
        end
      end
    end
  end

  context 'qualified with autosave' do
    context 'when the association has been configured with autosave: true' do
      it 'matches' do
        pending 'TODO'

        record = record_belonging_to(
          :parent,
          model_name: 'Child',
          autosave: true,
        )

        expect { belong_to(:parent).autosave }.
          to match_against(record).
          or_fail_with(<<~MESSAGE, unwrap: true)
            Did not expect Child to have a belongs_to association called parent
          MESSAGE
      end
    end

    context 'when the association has been configured with autosave: false' do
      it 'does not match' do
        pending 'TODO'

        record = record_belonging_to(
          :parent,
          model_name: 'Child',
          autosave: false,
        )

        expect { belong_to(:parent).autosave }.
          not_to match_against(record).
          and_fail_with(<<~MESSAGE, unwrap: true)
            Expected Child to have a belongs_to association called parent
            (parent should have autosave => true)
          MESSAGE
      end
    end

    context 'when the association has not been configured with :autosave at all' do
      it 'does not match' do
        pending 'TODO'

        record = record_belonging_to(:parent, model_name: 'Child')

        expect { belong_to(:parent).autosave }.
          not_to match_against(record).
          and_fail_with(<<~MESSAGE, unwrap: true)
            Expected Child to have a belongs_to association called parent
            (parent should have autosave => true)
          MESSAGE
      end
    end
  end

  context 'qualified with autosave(true)' do
    context 'when the association has been configured with autosave: true' do
      it 'matches' do
        record = record_belonging_to(
          :parent,
          model_name: 'Child',
          autosave: true,
        )

        expect { belong_to(:parent).autosave(true) }.
          to match_against(record).
          or_fail_with(<<~MESSAGE, unwrap: true)
            Did not expect Child to have a belongs_to association called parent
          MESSAGE
      end
    end

    context 'when the association has been configured with autosave: false' do
      it 'does not match' do
        record = record_belonging_to(
          :parent,
          model_name: 'Child',
          autosave: false,
        )

        expect { belong_to(:parent).autosave(true) }.
          not_to match_against(record).
          and_fail_with(<<~MESSAGE, unwrap: true)
            Expected Child to have a belongs_to association called parent
            (parent should have autosave set to true)
          MESSAGE
      end
    end

    context 'when the association has not been configured with :autosave at all' do
      it 'does not match' do
        record = record_belonging_to(:parent, model_name: 'Child')

        expect { belong_to(:parent).autosave(true) }.
          not_to match_against(record).
          and_fail_with(<<~MESSAGE, unwrap: true)
            Expected Child to have a belongs_to association called parent
            (parent should have autosave set to true)
          MESSAGE
      end
    end
  end

  context 'qualified with autosave(false)' do
    context 'when the association has been configured with autosave: true' do
      it 'does not match' do
        record = record_belonging_to(
          :parent,
          model_name: 'Child',
          autosave: true,
        )

        expect { belong_to(:parent).autosave(false) }.
          not_to match_against(record).
          and_fail_with(<<~MESSAGE, unwrap: true)
            Expected Child to have a belongs_to association called parent
            (parent should have autosave set to false)
          MESSAGE
      end
    end

    context 'when the association has been configured with autosave: false' do
      it 'matches' do
        record = record_belonging_to(
          :parent,
          model_name: 'Child',
          autosave: false,
        )

        expect { belong_to(:parent).autosave(false) }.
          to match_against(record).
          or_fail_with(<<~MESSAGE, unwrap: true)
            Did not expect Child to have a belongs_to association called parent
          MESSAGE
      end
    end

    context 'when the association has not been configured with :autosave at all' do
      it 'matches' do
        record = record_belonging_to(:parent, model_name: 'Child')

        expect { belong_to(:parent).autosave(false) }.
          to match_against(record).
          or_fail_with(<<~MESSAGE, unwrap: true)
            Did not expect Child to have a belongs_to association called parent
          MESSAGE
      end
    end
  end

  context 'qualified with validate' do
    context 'when the association has been configured with validate: true' do
      it 'matches' do
        record = record_belonging_to(
          :parent,
          model_name: 'Child',
          validate: true,
        )

        expect { belong_to(:parent).validate }.
          to match_against(record).
          or_fail_with(<<~MESSAGE, unwrap: true)
            Did not expect Child to have a belongs_to association called parent
          MESSAGE
      end
    end

    context 'when the association has been configured with validate: false' do
      it 'does not match' do
        record = record_belonging_to(
          :parent,
          model_name: 'Child',
          validate: false,
        )

        expect { belong_to(:parent).validate }.
          not_to match_against(record).
          and_fail_with(<<~MESSAGE, unwrap: true)
            Expected Child to have a belongs_to association called parent
            (parent should have validate: true)
          MESSAGE
      end
    end

    context 'when the association has not been configured with :validate at all' do
      it 'does not match' do
        record = record_belonging_to(:parent, model_name: 'Child')

        expect { belong_to(:parent).validate }.
          not_to match_against(record).
          and_fail_with(<<~MESSAGE, unwrap: true)
            Expected Child to have a belongs_to association called parent
            (parent should have validate: true)
          MESSAGE
      end
    end
  end

  context 'qualified with validate(true)' do
    context 'when the association has been configured with validate: true' do
      it 'matches' do
        record = record_belonging_to(
          :parent,
          model_name: 'Child',
          validate: true,
        )

        expect { belong_to(:parent).validate(true) }.
          to match_against(record).
          or_fail_with(<<~MESSAGE, unwrap: true)
            Did not expect Child to have a belongs_to association called parent
          MESSAGE
      end
    end

    context 'when the association has been configured with validate: false' do
      it 'does not match' do
        record = record_belonging_to(
          :parent,
          model_name: 'Child',
          validate: false,
        )

        expect { belong_to(:parent).validate(true) }.
          not_to match_against(record).
          and_fail_with(<<~MESSAGE, unwrap: true)
            Expected Child to have a belongs_to association called parent
            (parent should have validate: true)
          MESSAGE
      end
    end

    context 'when the association has not been configured with :validate at all' do
      it 'does not match' do
        record = record_belonging_to(:parent, model_name: 'Child')

        expect { belong_to(:parent).validate(true) }.
          not_to match_against(record).
          and_fail_with(<<~MESSAGE, unwrap: true)
            Expected Child to have a belongs_to association called parent
            (parent should have validate: true)
          MESSAGE
      end
    end
  end

  context 'qualified with validate(false)' do
    context 'when the association has been configured with validate: true' do
      it 'does not match' do
        record = record_belonging_to(
          :parent,
          model_name: 'Child',
          validate: true,
        )

        expect { belong_to(:parent).validate(false) }.
          not_to match_against(record).
          and_fail_with(<<~MESSAGE, unwrap: true)
            Expected Child to have a belongs_to association called parent
            (parent should have validate: false)
          MESSAGE
      end
    end

    context 'when the association has been configured with validate: false' do
      it 'matches' do
        record = record_belonging_to(
          :parent,
          model_name: 'Child',
          validate: false,
        )

        expect { belong_to(:parent).validate(false) }.
          to match_against(record).
          or_fail_with(<<~MESSAGE, unwrap: true)
            Did not expect Child to have a belongs_to association called parent
          MESSAGE
      end
    end

    context 'when the association has not been configured with :validate at all' do
      it 'matches' do
        record = record_belonging_to(:parent, model_name: 'Child')

        expect { belong_to(:parent).validate(false) }.
          to match_against(record).
          or_fail_with(<<~MESSAGE, unwrap: true)
            Did not expect Child to have a belongs_to association called parent
          MESSAGE
      end
    end
  end

  context 'qualified with touch' do
    context 'when the association has been configured with touch: true' do
      it 'matches' do
        record = record_belonging_to(
          :parent,
          model_name: 'Child',
          touch: true,
        )

        expect { belong_to(:parent).touch }.
          to match_against(record).
          or_fail_with(<<~MESSAGE, unwrap: true)
            Did not expect Child to have a belongs_to association called parent
          MESSAGE
      end
    end

    context 'when the association has been configured with touch: false' do
      it 'does not match' do
        record = record_belonging_to(
          :parent,
          model_name: 'Child',
          touch: false,
        )

        expect { belong_to(:parent).touch }.
          not_to match_against(record).
          and_fail_with(<<~MESSAGE, unwrap: true)
            Expected Child to have a belongs_to association called parent
            (parent should have touch: true)
          MESSAGE
      end
    end

    context 'when the association has not been configured with :touch at all' do
      it 'does not match' do
        record = record_belonging_to(:parent, model_name: 'Child')

        expect { belong_to(:parent).touch }.
          not_to match_against(record).
          and_fail_with(<<~MESSAGE, unwrap: true)
            Expected Child to have a belongs_to association called parent
            (parent should have touch: true)
          MESSAGE
      end
    end
  end

  context 'qualified with touch(true)' do
    context 'when the association has been configured with touch: true' do
      it 'matches' do
        record = record_belonging_to(
          :parent,
          model_name: 'Child',
          touch: true,
        )

        expect { belong_to(:parent).touch(true) }.
          to match_against(record).
          or_fail_with(<<~MESSAGE, unwrap: true)
            Did not expect Child to have a belongs_to association called parent
          MESSAGE
      end
    end

    context 'when the association has been configured with touch: false' do
      it 'does not match' do
        record = record_belonging_to(
          :parent,
          model_name: 'Child',
          touch: false,
        )

        expect { belong_to(:parent).touch(true) }.
          not_to match_against(record).
          and_fail_with(<<~MESSAGE, unwrap: true)
            Expected Child to have a belongs_to association called parent
            (parent should have touch: true)
          MESSAGE
      end
    end

    context 'when the association has not been configured with :touch at all' do
      it 'does not match' do
        record = record_belonging_to(:parent, model_name: 'Child')

        expect { belong_to(:parent).touch(true) }.
          not_to match_against(record).
          and_fail_with(<<~MESSAGE, unwrap: true)
            Expected Child to have a belongs_to association called parent
            (parent should have touch: true)
          MESSAGE
      end
    end
  end

  context 'qualified with touch(false)' do
    context 'when the association has been configured with touch: true' do
      it 'does not match' do
        record = record_belonging_to(
          :parent,
          model_name: 'Child',
          touch: true,
        )

        expect { belong_to(:parent).touch(false) }.
          not_to match_against(record).
          and_fail_with(<<~MESSAGE, unwrap: true)
            Expected Child to have a belongs_to association called parent
            (parent should have touch: false)
          MESSAGE
      end
    end

    context 'when the association has been configured with touch: false' do
      it 'matches' do
        record = record_belonging_to(
          :parent,
          model_name: 'Child',
          touch: false,
        )

        expect { belong_to(:parent).touch(false) }.
          to match_against(record).
          or_fail_with(<<~MESSAGE, unwrap: true)
            Did not expect Child to have a belongs_to association called parent
          MESSAGE
      end
    end

    context 'when the association has not been configured with :touch at all' do
      it 'matches' do
        record = record_belonging_to(:parent, model_name: 'Child')

        expect { belong_to(:parent).touch(false) }.
          to match_against(record).
          or_fail_with(<<~MESSAGE, unwrap: true)
            Did not expect Child to have a belongs_to association called parent
          MESSAGE
      end
    end
  end

  [
    ['required(true)', [true]],
    ['required', []],
  ].each do |qualifier_description, qualifier_args|
    context "qualified with #{qualifier_description}" do
      context 'when the association has been configured to be neither required nor optional' do
        if active_record_supports_optional_for_associations?
          context 'when belongs_to is configured to be required by default' do
            it 'matches' do
              with_belongs_to_as_required_by_default do
                record = record_belonging_to(:parent, model_name: 'Child')

                expect { belong_to(:parent).required(*qualifier_args) }.
                  to match_against(record).
                  or_fail_with(<<~MESSAGE, unwrap: true)
                    Did not expect Child to have a belongs_to association called
                    parent
                  MESSAGE
              end
            end
          end

          context 'when belongs_to is not configured to be required by default' do
            it 'does not match' do
              with_belongs_to_as_optional_by_default do
                record = record_belonging_to(:parent, model_name: 'Child')

                expect { belong_to(:parent).required(*qualifier_args) }.
                  not_to match_against(record).
                  and_fail_with(<<~MESSAGE, unwrap: true)
                    Expected Child to have a belongs_to association called parent
                    (and for the record to fail validation if :parent is unset;
                    i.e., either the association should have been defined with
                    `required: true`, or there should be a presence validation on
                    :parent)
                  MESSAGE
              end
            end
          end
        else
          it 'does not match' do
            record = record_belonging_to(:parent)

            expect { belong_to(:parent).required(*qualifier_args) }.
              not_to match_against(record).
              and_fail_with(<<~MESSAGE, unwrap: true)
                Expected Child to have a belongs_to association called parent
                (and for the record to fail validation if :parent is unset;
                i.e., either the association should have been defined with
                `required: true`, or there should be a presence validation on
                :parent)
              MESSAGE
          end
        end
      end

      context 'when the association has been configured with required: true' do
        it 'matches' do
          record = record_belonging_to(
            :parent,
            model_name: 'Child',
            required: true,
          )

          expect { belong_to(:parent).required(*qualifier_args) }.
            to match_against(record).
            or_fail_with(<<~MESSAGE, unwrap: true)
              Did not expect Child to have a belongs_to association called
              parent
            MESSAGE
        end
      end

      context 'when the association has been configured with optional: true' do
        if active_record_supports_optional_for_associations?
          it 'does not match' do
            record = record_belonging_to(
              :parent,
              model_name: 'Child',
              optional: true,
            )

            expect { belong_to(:parent).required(*qualifier_args) }.
              not_to match_against(record).
              and_fail_with(<<~MESSAGE, unwrap: true)
                Expected Child to have a belongs_to association called parent
                (and for the record to fail validation if :parent is unset;
                i.e., either the association should have been defined with
                `required: true`, or there should be a presence validation on
                :parent)
              MESSAGE
          end
        end
      end

      context 'when the model manually ensures the association is set' do
        context 'and the matcher is not qualified with without_validating_presence' do
          it 'does not match' do
            record = record_belonging_to(:parent, model_name: 'Child') do
              before_validation :ensure_parent_is_set

              def ensure_parent_is_set
                self.parent = Parent.create
              end
            end

            expect { belong_to(:parent).required }.
              not_to match_against(record).
              and_fail_with(<<~MESSAGE, unwrap: true)
                Expected Child to have a belongs_to association called parent
                (and for the record to fail validation if :parent is unset;
                i.e., either the association should have been defined with
                `required: true`, or there should be a presence validation on
                :parent)
              MESSAGE
          end
        end

        context 'and the matcher is also qualified with without_validating_presence' do
          it 'matches' do
            record = record_belonging_to(:parent, model_name: 'Child') do
              before_validation :ensure_parent_is_set

              def ensure_parent_is_set
                self.parent = Parent.create
              end
            end

            expect { belong_to(:parent).required.without_validating_presence }.
              to match_against(record).
              or_fail_with(<<~MESSAGE, unwrap: true)
                Did not expect Child to have a belongs_to association called
                parent
              MESSAGE
          end
        end
      end
    end
  end

  context 'qualified with required(false)' do
    context 'when the association has been configured to be neither required nor optional' do
      if active_record_supports_optional_for_associations?
        context 'when belongs_to is configured to be required by default' do
          it 'does not match' do
            with_belongs_to_as_required_by_default do
              record = record_belonging_to(:parent, model_name: 'Child')

              expect { belong_to(:parent).required(false) }.
                not_to match_against(record).
                and_fail_with(<<~MESSAGE, unwrap: true)
                  Expected Child to have a belongs_to association called parent
                  (and for the record not to fail validation if :parent is
                  unset; i.e., either the association should have been defined
                  with `required: false`, or there should not be a presence
                  validation on :parent)
                MESSAGE
            end
          end
        end

        context 'when belongs_to is not configured to be required by default' do
          it 'matches' do
            with_belongs_to_as_optional_by_default do
              record = record_belonging_to(:parent, model_name: 'Child')

              expect { belong_to(:parent).required(false) }.
                to match_against(record).
                or_fail_with(<<~MESSAGE, unwrap: true)
                  Did not expect Child to have a belongs_to association called
                  parent
                MESSAGE
            end
          end
        end
      else
        it 'matches' do
          record = record_belonging_to(:parent, model_name: 'Child')

          expect { belong_to(:parent).required(false) }.
            to match_against(record).
            or_fail_with(<<~MESSAGE, unwrap: true)
              Did not expect Child to have a belongs_to association called
              parent
            MESSAGE
        end
      end
    end

    context 'when the association has been configured with required: true' do
      it 'does not match' do
        record = record_belonging_to(
          :parent,
          model_name: 'Child',
          required: true,
        )

        expect { belong_to(:parent).required(false) }.
          not_to match_against(record).
          and_fail_with(<<~MESSAGE, unwrap: true)
            Expected Child to have a belongs_to association called parent
            (and for the record not to fail validation if :parent is
            unset; i.e., either the association should have been defined
            with `required: false`, or there should not be a presence
            validation on :parent)
          MESSAGE
      end
    end

    if active_record_supports_optional_for_associations?
      context 'when the association has been configured with optional: true' do
        it 'matches' do
          record = record_belonging_to(
            :parent,
            model_name: 'Child',
            optional: true,
          )

          expect { belong_to(:parent).required(false) }.
            to match_against(record).
            or_fail_with(<<~MESSAGE, unwrap: true)
              Did not expect Child to have a belongs_to association called
              parent
            MESSAGE
        end
      end
    end
  end

  context 'qualified with optional' do
    if active_record_supports_optional_for_associations?
      context 'when the association has been configured with neither optional nor required' do
        context 'when belongs_to is configured to be required by default' do
          it 'does not match' do
            with_belongs_to_as_required_by_default do
              record = record_belonging_to(:parent, model_name: 'Child')

              expect { belong_to(:parent).optional }.
                not_to match_against(record).
                and_fail_with(<<~MESSAGE, unwrap: true)
                  Expected Child to have a belongs_to association called parent
                  (and for the record not to fail validation if :parent is
                  unset; i.e., either the association should have been defined
                  with `optional: true`, or there should not be a presence
                  validation on :parent)
                MESSAGE
            end
          end
        end

        context 'when belongs_to is not configured to be required by default' do
          it 'matches' do
            with_belongs_to_as_optional_by_default do
              record = record_belonging_to(:parent, model_name: 'Child')

              expect { belong_to(:parent).optional }.
                to match_against(record).
                or_fail_with(<<~MESSAGE, unwrap: true)
                  Did not expect Child to have a belongs_to association called
                  parent
                MESSAGE
            end
          end
        end
      end

      context 'when the association has been configured with optional: true' do
        it 'matches' do
          record = record_belonging_to(
            :parent,
            model_name: 'Child',
            optional: true,
          )

          expect { belong_to(:parent).optional }.
            to match_against(record).
            or_fail_with(<<~MESSAGE, unwrap: true)
              Did not expect Child to have a belongs_to association called
              parent
            MESSAGE
        end
      end
    else
      it 'matches' do
        record = record_belonging_to(:parent, model_name: 'Child')

        expect { belong_to(:parent).optional }.
          to match_against(record).
          or_fail_with(<<~MESSAGE, unwrap: true)
            Did not expect Child to have a belongs_to association called parent
          MESSAGE
      end
    end

    context 'when the association has been configured with required: true' do
      it 'does not match' do
        record = record_belonging_to(
          :parent,
          model_name: 'Child',
          required: true,
        )

        expect { belong_to(:parent).optional }.
          not_to match_against(record).
          and_fail_with(<<~MESSAGE, unwrap: true)
            Expected Child to have a belongs_to association called parent
            (and for the record not to fail validation if :parent is
            unset; i.e., either the association should have been defined
            with `optional: true`, or there should not be a presence
            validation on :parent)
          MESSAGE
      end
    end
  end

  context 'qualified with without_validating_presence' do
    context 'when the model manually ensures the association is set' do
      it 'matches' do
        record = record_belonging_to(:parent, model_name: 'Child') do
          before_validation :ensure_parent_is_set

          def ensure_parent_is_set
            self.parent = Parent.create
          end
        end

        expect { belong_to(:parent).without_validating_presence }.
          to match_against(record).
          or_fail_with(<<~MESSAGE, unwrap: true)
            Did not expect Child to have a belongs_to association called parent
          MESSAGE
      end
    end
  end

  def record_belonging_to(attribute_name, **options, &block)
    model_belonging_to(attribute_name, **options, &block).new
  end

  def model_belonging_to(
    attribute_name,
    model_name: 'Whatever',
    parent_model_name: 'Parent',
    column_name: "#{attribute_name}_id",
    extra_columns: {},
    include_has_many: false,
    scope: nil,
    **association_options,
    &block
  )
    define_model(parent_model_name) do
      if include_has_many
        has_many association_options[:inverse_of]
      end
    end

    define_model(
      model_name,
      { column_name => :integer }.merge(extra_columns),
    ) do
      if scope
        belongs_to(attribute_name, scope, **association_options)
      else
        belongs_to(attribute_name, **association_options)
      end

      if block
        class_eval(&block)
      end
    end
  end
end
