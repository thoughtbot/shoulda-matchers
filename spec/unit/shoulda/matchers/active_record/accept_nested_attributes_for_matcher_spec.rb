require 'unit_spec_helper'

describe Shoulda::Matchers::ActiveRecord::AcceptNestedAttributesForMatcher, type: :model do
  it 'accepts an existing declaration' do
    expect(accepting_children).to accept_nested_attributes_for(:children)
  end

  it 'rejects a missing declaration' do
    matcher = children_matcher

    expect(matcher.matches?(rejecting_children)).to eq false

    expect(matcher.failure_message).
      to eq 'Expected Parent to accept nested attributes for children (is not declared)'
  end

  context 'allow_destroy' do
    it 'accepts a valid truthy value' do
      matching = accepting_children(allow_destroy: true)

      expect(matching).to children_matcher.allow_destroy(true)
    end

    it 'accepts a valid falsey value' do
      matching = accepting_children(allow_destroy: false)

      expect(matching).to children_matcher.allow_destroy(false)
    end

    it 'rejects an invalid truthy value' do
      matcher = children_matcher
      matching = accepting_children(allow_destroy: true)

      expect(matcher.allow_destroy(false).matches?(matching)).to eq false
      expect(matcher.failure_message).to match(/should not allow destroy/)
    end

    it 'rejects an invalid falsey value' do
      matcher = children_matcher
      matching = accepting_children(allow_destroy: false)

      expect(matcher.allow_destroy(true).matches?(matching)).to eq false
      expect(matcher.failure_message).to match(/should allow destroy/)
    end
  end

  context 'reject_if' do
    context 'when the option on the association is not a proc' do
      context 'when the association option is true' do
        context 'and the given option is true' do
          it 'matches' do
            record = accepting_children(reject_if: true)

            expect { children_matcher.reject_if(true) }.
              to match_against(record).
              or_fail_with(<<-MESSAGE)
Did not expect Parent to accept nested attributes for children
              MESSAGE
          end
        end

        context 'and the given option is false' do
          it 'does not match, producing an appropriate message' do
            record = accepting_children(reject_if: true)

            expect { children_matcher.reject_if(false) }.
              not_to match_against(record).
              and_fail_with(<<-MESSAGE)
Expected Parent to accept nested attributes for children (reject_if should resolve to false, got true)
              MESSAGE
          end
        end
      end

      context 'when the association option is false' do
        context 'and the given option is false' do
          it 'matches' do
            record = accepting_children(reject_if: false)

            expect { children_matcher.reject_if(false) }.
              to match_against(record).
              or_fail_with(<<-MESSAGE)
Did not expect Parent to accept nested attributes for children
              MESSAGE
          end
        end

        context 'and the given option is false' do
          it 'does not match, producing an appropriate message' do
            record = accepting_children(reject_if: false)

            expect { children_matcher.reject_if(true) }.
              not_to match_against(record).
              and_fail_with(<<-MESSAGE)
Expected Parent to accept nested attributes for children (reject_if should resolve to true, got false)
              MESSAGE
          end
        end
      end
    end

    context 'when the option on the association is a proc' do
      context 'and it returns true' do
        context 'and the given option is true' do
          it 'matches' do
            record = accepting_children(reject_if: ->(_unused) { true })

            expect { children_matcher.reject_if(true) }.
              to match_against(record).
              or_fail_with(<<-MESSAGE)
Did not expect Parent to accept nested attributes for children
              MESSAGE
          end
        end

        context 'and the given option is false' do
          it 'does not match, producing an appropriate message' do
            record = accepting_children(reject_if: ->(_unused) { true })

            expect { children_matcher.reject_if(false) }.
              not_to match_against(record).
              and_fail_with(<<-MESSAGE)
Expected Parent to accept nested attributes for children (reject_if should resolve to false, got true)
              MESSAGE
          end
        end
      end

      context 'and it returns false' do
        context 'and the given option is false' do
          it 'matches' do
            record = accepting_children(reject_if: ->(_unused) { false })

            expect { children_matcher.reject_if(false) }.
              to match_against(record).
              or_fail_with(<<-MESSAGE)
Did not expect Parent to accept nested attributes for children
              MESSAGE
          end
        end

        context 'and the given option is true' do
          it 'does not match, producing an appropriate message' do
            record = accepting_children(reject_if: ->(_unused) { false })

            expect { children_matcher.reject_if(true) }.
              not_to match_against(record).
              and_fail_with(<<-MESSAGE)
Expected Parent to accept nested attributes for children (reject_if should resolve to true, got false)
              MESSAGE
          end
        end
      end
    end

    context 'when the option on the association is a symbol' do
      context 'and a method by that name exists on the model' do
        context 'and it is public' do
          context 'and it returns true' do
            context 'and the given option is true' do
              it 'matches' do
                record = accepting_children(reject_if: :truthy_method) do
                  public def truthy_method; true; end
                end

                expect { children_matcher.reject_if(true) }.
                  to match_against(record).
                  or_fail_with(<<-MESSAGE)
Did not expect Parent to accept nested attributes for children
                  MESSAGE
              end
            end

            context 'and the given option is false' do
              it 'does not match, producing an appropriate message' do
                record = accepting_children(reject_if: :truthy_method) do
                  public def truthy_method; true; end
                end

                expect { children_matcher.reject_if(false) }.
                  not_to match_against(record).
                  and_fail_with(<<-MESSAGE)
Expected Parent to accept nested attributes for children (reject_if should resolve to false, got true)
                  MESSAGE
              end
            end
          end

          context 'and it returns false' do
            context 'and the given option is false' do
              it 'matches' do
                record = accepting_children(reject_if: :falsey_method) do
                  public def falsey_method; false; end
                end

                expect { children_matcher.reject_if(false) }.
                  to match_against(record).
                  or_fail_with(<<-MESSAGE)
Did not expect Parent to accept nested attributes for children
                  MESSAGE
              end
            end

            context 'and the given option is true' do
              it 'does not match, producing an appropriate message' do
                record = accepting_children(reject_if: :falsey_method) do
                  public def falsey_method; false; end
                end

                expect { children_matcher.reject_if(true) }.
                  not_to match_against(record).
                  and_fail_with(<<-MESSAGE)
Expected Parent to accept nested attributes for children (reject_if should resolve to true, got false)
                  MESSAGE
              end
            end
          end
        end

        context 'and it is private' do
          context 'and it returns true' do
            context 'and the given option is true' do
              it 'matches' do
                record = accepting_children(reject_if: :truthy_method) do
                  private def truthy_method; true; end
                end

                expect { children_matcher.reject_if(true) }.
                  to match_against(record).
                  or_fail_with(<<-MESSAGE)
Did not expect Parent to accept nested attributes for children
                  MESSAGE
              end
            end

            context 'and the given option is false' do
              it 'does not match, producing an appropriate message' do
                record = accepting_children(reject_if: :truthy_method) do
                  private def truthy_method; true; end
                end

                expect { children_matcher.reject_if(false) }.
                  not_to match_against(record).
                  and_fail_with(<<-MESSAGE)
    Expected Parent to accept nested attributes for children (reject_if should resolve to false, got true)
                  MESSAGE
              end
            end
          end

          context 'and it returns false' do
            context 'and the given option is false' do
              it 'matches' do
                record = accepting_children(reject_if: :falsey_method) do
                  private def falsey_method; false; end
                end

                expect { children_matcher.reject_if(false) }.
                  to match_against(record).
                  or_fail_with(<<-MESSAGE)
    Did not expect Parent to accept nested attributes for children
                  MESSAGE
              end
            end

            context 'and the given option is true' do
              it 'does not match, producing an appropriate message' do
                record = accepting_children(reject_if: :falsey_method) do
                  private def falsey_method; false; end
                end

                expect { children_matcher.reject_if(true) }.
                  not_to match_against(record).
                  and_fail_with(<<-MESSAGE)
    Expected Parent to accept nested attributes for children (reject_if should resolve to true, got false)
                  MESSAGE
              end
            end
          end
        end
      end

      context 'and a method by that name does not exist on the model' do
        it 'does not match, producing an appropriate message' do
          record = accepting_children(reject_if: :unknown_method)

          expect { children_matcher.reject_if(true) }.
            not_to match_against(record).
            and_fail_with(<<-MESSAGE)
Expected Parent to accept nested attributes for children (reject_if should resolve to true, but :unknown_method does not exist on Parent)
            MESSAGE
        end
      end
    end
  end

  context 'limit' do
    it 'accepts a correct value' do
      expect(accepting_children(limit: 3)).to children_matcher.limit(3)
    end

    it 'rejects a false value' do
      matcher = children_matcher
      rejecting = accepting_children(limit: 3)

      expect(matcher.limit(2).matches?(rejecting)).to eq false
      expect(matcher.failure_message).to match(/limit should be 2, got 3/)
    end
  end

  context 'update_only' do
    it 'accepts a valid truthy value' do
      expect(accepting_children(update_only: true)).
        to children_matcher.update_only(true)
    end

    it 'accepts a valid falsey value' do
      expect(accepting_children(update_only: false)).
        to children_matcher.update_only(false)
    end

    it 'rejects an invalid truthy value' do
      matcher = children_matcher.update_only(false)
      rejecting = accepting_children(update_only: true)

      expect(matcher.matches?(rejecting)).to eq false
      expect(matcher.failure_message).to match(/should not be update only/)
    end

    it 'rejects an invalid falsey value' do
      matcher = children_matcher.update_only(true)
      rejecting = accepting_children(update_only: false)

      expect(matcher.matches?(rejecting)).to eq false
      expect(matcher.failure_message).to match(/should be update only/)
    end
  end

  def accepting_children(options = {}, &block)
    define_model :child, parent_id: :integer

    parent_model = define_model :parent do
      has_many :children
      accepts_nested_attributes_for :children, options

      if block
        class_eval(&block)
      end
    end

    parent_model.new
  end

  def children_matcher
    accept_nested_attributes_for(:children)
  end

  def rejecting_children
    define_model :child, parent_id: :integer
    define_model :parent do
      has_many :children
    end.new
  end
end
