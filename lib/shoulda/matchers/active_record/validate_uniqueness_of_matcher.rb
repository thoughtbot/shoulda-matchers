module Shoulda
  module Matchers
    module ActiveRecord
      # The `validate_uniqueness_of` matcher tests usage of the
      # `validates_uniqueness_of` validation. It first checks for an existing
      # instance of your model in the database, creating one if necessary. It
      # then takes a new instance of that model and asserts that it fails
      # validation if the attribute or attributes you've specified in the
      # validation are set to values which are the same as those of the
      # pre-existing record (thereby failing the uniqueness check).
      #
      #     class Post < ActiveRecord::Base
      #       validates_uniqueness_of :permalink
      #     end
      #
      #     # RSpec
      #     RSpec.describe Post, type: :model do
      #       it { should validate_uniqueness_of(:permalink) }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class PostTest < ActiveSupport::TestCase
      #       should validate_uniqueness_of(:permalink)
      #     end
      #
      # #### Caveat
      #
      # This matcher works a bit differently than other matchers. As noted
      # before, it will create an instance of your model if one doesn't already
      # exist. Sometimes this step fails, especially if you have database-level
      # restrictions on any attributes other than the one which is unique. In
      # this case, the solution is to populate these attributes with values
      # before you call `validate_uniqueness_of`.
      #
      # For example, say you have the following migration and model:
      #
      #     class CreatePosts < ActiveRecord::Migration
      #       def change
      #         create_table :posts do |t|
      #           t.string :title
      #           t.text :content, null: false
      #         end
      #       end
      #     end
      #
      #     class Post < ActiveRecord::Base
      #       validates :title, uniqueness: true
      #     end
      #
      # You may be tempted to test the model like this:
      #
      #     RSpec.describe Post, type: :model do
      #       it { should validate_uniqueness_of(:title) }
      #     end
      #
      # However, running this test will fail with an exception such as:
      #
      #     Shoulda::Matchers::ActiveRecord::ValidateUniquenessOfMatcher::ExistingRecordInvalid:
      #       validate_uniqueness_of works by matching a new record against an
      #       existing record. If there is no existing record, it will create one
      #       using the record you provide.
      #
      #       While doing this, the following error was raised:
      #
      #         PG::NotNullViolation: ERROR:  null value in column "content" violates not-null constraint
      #         DETAIL:  Failing row contains (1, null, null).
      #         : INSERT INTO "posts" DEFAULT VALUES RETURNING "id"
      #
      #       The best way to fix this is to provide the matcher with a record where
      #       any required attributes are filled in with valid values beforehand.
      #
      # (The exact error message will differ depending on which database you're
      # using, but you get the idea.)
      #
      # This happens because `validate_uniqueness_of` tries to create a new post
      # but cannot do so because of the `content` attribute: though unrelated to
      # this test, it nevertheless needs to be filled in. As indicated at the
      # end of the error message, the solution is to build a custom Post object
      # ahead of time with `content` filled in:
      #
      #     RSpec.describe Post, type: :model do
      #       describe "validations" do
      #         subject { Post.create(content: "Here is the content") }
      #         it { should validate_uniqueness_of(:title) }
      #       end
      #     end
      #
      # Or, if you're using
      # [FactoryGirl](http://github.com/thoughtbot/factory_girl) and you have a
      # `post` factory defined which automatically fills in `content`, you can
      # say:
      #
      #     RSpec.describe Post, type: :model do
      #       describe "validations" do
      #         subject { FactoryGirl.create(:post) }
      #         it { should validate_uniqueness_of(:title) }
      #       end
      #     end
      #
      # #### Qualifiers
      #
      # Use `on` if your validation applies only under a certain context.
      #
      #     class Post < ActiveRecord::Base
      #       validates_uniqueness_of :title, on: :create
      #     end
      #
      #     # RSpec
      #     RSpec.describe Post, type: :model do
      #       it { should validate_uniqueness_of(:title).on(:create) }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class PostTest < ActiveSupport::TestCase
      #       should validate_uniqueness_of(:title).on(:create)
      #     end
      #
      # ##### with_message
      #
      # Use `with_message` if you are using a custom validation message.
      #
      #     class Post < ActiveRecord::Base
      #       validates_uniqueness_of :title, message: 'Please choose another title'
      #     end
      #
      #     # RSpec
      #     RSpec.describe Post, type: :model do
      #       it do
      #         should validate_uniqueness_of(:title).
      #           with_message('Please choose another title')
      #       end
      #     end
      #
      #     # Minitest (Shoulda)
      #     class PostTest < ActiveSupport::TestCase
      #       should validate_uniqueness_of(:title).
      #         with_message('Please choose another title')
      #     end
      #
      # ##### scoped_to
      #
      # Use `scoped_to` to test usage of the `:scope` option. This asserts that
      # a new record fails validation if not only the primary attribute is not
      # unique, but the scoped attributes are not unique either.
      #
      #     class Post < ActiveRecord::Base
      #       validates_uniqueness_of :slug, scope: :journal_id
      #     end
      #
      #     # RSpec
      #     RSpec.describe Post, type: :model do
      #       it { should validate_uniqueness_of(:slug).scoped_to(:journal_id) }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class PostTest < ActiveSupport::TestCase
      #       should validate_uniqueness_of(:slug).scoped_to(:journal_id)
      #     end
      #
      # ##### case_insensitive
      #
      # Use `case_insensitive` to test usage of the `:case_sensitive` option
      # with a false value. This asserts that the uniquable attributes fail
      # validation even if their values are a different case than corresponding
      # attributes in the pre-existing record.
      #
      #     class Post < ActiveRecord::Base
      #       validates_uniqueness_of :key, case_sensitive: false
      #     end
      #
      #     # RSpec
      #     RSpec.describe Post, type: :model do
      #       it { should validate_uniqueness_of(:key).case_insensitive }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class PostTest < ActiveSupport::TestCase
      #       should validate_uniqueness_of(:key).case_insensitive
      #     end
      #
      # ##### ignoring_case_sensitivity
      #
      # By default, `validate_uniqueness_of` will check that the
      # validation is case sensitive: it asserts that uniquable attributes pass
      # validation when their values are in a different case than corresponding
      # attributes in the pre-existing record.
      #
      # Use `ignoring_case_sensitivity` to skip this check. This qualifier is
      # particularly handy if your model has somehow changed the behavior of
      # attribute you're testing so that it modifies the case of incoming values
      # as they are set. For instance, perhaps you've overridden the writer
      # method or added a `before_validation` callback to normalize the
      # attribute.
      #
      #     class User < ActiveRecord::Base
      #       validates_uniqueness_of :email
      #
      #       def email=(value)
      #         super(value.downcase)
      #       end
      #     end
      #
      #     # RSpec
      #     RSpec.describe Post, type: :model do
      #       it do
      #         should validate_uniqueness_of(:email).ignoring_case_sensitivity
      #       end
      #     end
      #
      #     # Minitest (Shoulda)
      #     class PostTest < ActiveSupport::TestCase
      #       should validate_uniqueness_of(:email).ignoring_case_sensitivity
      #     end
      #
      # ##### allow_nil
      #
      # Use `allow_nil` to assert that the attribute allows nil.
      #
      #     class Post < ActiveRecord::Base
      #       validates_uniqueness_of :author_id, allow_nil: true
      #     end
      #
      #     # RSpec
      #     RSpec.describe Post, type: :model do
      #       it { should validate_uniqueness_of(:author_id).allow_nil }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class PostTest < ActiveSupport::TestCase
      #       should validate_uniqueness_of(:author_id).allow_nil
      #     end
      #
      # @return [ValidateUniquenessOfMatcher]
      #
      # ##### allow_blank
      #
      # Use `allow_blank` to assert that the attribute allows a blank value.
      #
      #     class Post < ActiveRecord::Base
      #       validates_uniqueness_of :author_id, allow_blank: true
      #     end
      #
      #     # RSpec
      #     RSpec.describe Post, type: :model do
      #       it { should validate_uniqueness_of(:author_id).allow_blank }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class PostTest < ActiveSupport::TestCase
      #       should validate_uniqueness_of(:author_id).allow_blank
      #     end
      #
      # @return [ValidateUniquenessOfMatcher]
      #
      def validate_uniqueness_of(attr)
        ValidateUniquenessOfMatcher.new(attr)
      end

      # @private
      class ValidateUniquenessOfMatcher < ValidationMatcherWithExistingRecord
        module Helpers
          def arbitrary_non_blank_value
            limit = column_limit_for(attribute)
            non_blank_value = 'an arbitrary value'

            if limit && limit < non_blank_value.length
              'x' * limit
            else
              non_blank_value
            end
          end

          def column_limit_for(attribute)
            column_for(attribute).try(:limit)
          end

          def column_for(scope)
            model.columns_hash[scope.to_s]
          end
        end

        include Helpers

        def initialize(attribute)
          super(attribute)

          @options = {
            scopes: [],
            case_sensitivity_strategy: :sensitive,
            allow_nil: false,
            allow_blank: false,
          }

          @expected_message = :taken
        end

        def scoped_to(*scopes)
          options[:scopes] = [*scopes].flatten
          self
        end

        def case_insensitive
          options[:case_sensitivity_strategy] = :insensitive
          self
        end

        def ignoring_case_sensitivity
          options[:case_sensitivity_strategy] = :ignore
          self
        end

        def allow_nil
          options[:allow_nil] = true
          self
        end

        def expects_to_allow_nil?
          options[:allow_nil]
        end

        def allow_blank
          options[:allow_blank] = true
          self
        end

        def expects_to_allow_blank?
          options[:allow_blank]
        end

        def matches?(given_record)
          existing_record, existing_record_created =
            find_or_create_existing_record(given_record)

          new_record = initialize_new_record(existing_record)

          Uniqueness::TestModels.within_sandbox do
            super(
              new_record: new_record,
              existing_record: existing_record,
              existing_record_created: existing_record_created,
            )
          end
        end

        def before_match
          super

          if current_value_from_existing_record.blank?
            update_existing_record!(arbitrary_non_blank_value)
          end
        end

        protected

        def simple_description
          description = "validate that :#{attribute} is"
          description << description_for_case_sensitive_qualifier
          description << ' unique'

          if options[:scopes].present?
            description << ' within the scope of '
            description << inspected_expected_scope_attributes
          end

          description
        end

        def add_submatchers
          add_submatcher_to_verify_presence_of_attribute_and_scope_attributes
          add_submatcher_to_verify_presence_of_scopes_on_validation
          add_submatcher_to_test_uniqueness_of_non_blank_value

          # add_submatcher_to_test_case_sensitivity
          # add_submatchers_to_test_scopes
          # TODO
          # add_submatcher_for_allow_nil
          # add_submatcher_for_allow_blank
        end

        private

        attr_reader :options

        def expected_scope_attributes
          options[:scopes]
        end

        def case_sensitivity_strategy
          options[:case_sensitivity_strategy]
        end

        def find_or_create_existing_record(given_record)
          existing_record = find_existing_record(given_record)

          if existing_record
            [existing_record, false]
          else
            [create_existing_record(given_record), true]
          end
        end

        def find_existing_record(given_record)
          given_record.class.first.presence
        end

        def create_existing_record(given_record)
          given_record.tap do |existing_record|
            ensure_secure_password_set_on(existing_record)
            existing_record.save(validate: false)
          end
        rescue ::ActiveRecord::StatementInvalid => error
          raise ExistingRecordInvalid.create(underlying_exception: error)
        end

        def initialize_new_record(existing_record)
          existing_record.dup.tap do |new_record|
            attribute_names_under_test.each do |attribute_name|
              set_attribute_on!(
                :new_record,
                new_record,
                attribute_name,
                existing_record.public_send(attribute_name),
              )
            end
          end
        end

        def attribute_names_under_test
          [attribute] + expected_scope_attributes
        end

        def description_for_case_sensitive_qualifier
          case case_sensitivity_strategy
          when :sensitive
            ' case-sensitively'
          when :insensitive
            ' case-insensitively'
          else
            ''
          end
        end

        def add_submatcher_to_verify_presence_of_attribute_and_scope_attributes
          ([attribute] + expected_scope_attributes).each do |attr|
            add_submatcher(
              Shoulda::Matchers::ActiveModel::HaveAttributeMatcher,
              attr
            )
          end
        end

        def add_submatcher_to_verify_presence_of_validation
          add_submatcher(
            Shoulda::Matchers::ActiveModel::HaveValidationOn,
            attribute,
            ::ActiveRecord::Validations::UniquenessValidator,
            :uniqueness
          )
        end

        def add_submatcher_to_verify_presence_of_scopes_on_validation
          add_submatcher(
            HaveScopesMatcher,
            attribute,
            expected_scope_attributes,
            actual_uniqueness_validations
          )
        end

        def add_submatcher_to_test_uniqueness_of_non_blank_value
          add_submatcher(
            HaveUniqueAttribute,
            attribute,
            actual_uniqueness_validations
          )
        end

        def add_submatcher_for_allow_nil
          if expects_to_allow_nil?
            add_submatcher_allowing(nil) do |matcher|
              matcher.before_matching do
                update_existing_record!(nil)
              end
            end
          end
        end

        def add_submatcher_for_allow_blank
          if expects_to_allow_blank?
            add_submatcher_allowing('') do |matcher|
              matcher.before_matching do
                update_existing_record!('')
              end
            end
          end
        end

        def add_submatcher_to_test_case_sensitivity
          if should_validate_case_sensitivity?
            add_submatcher(
              CaseSensitivityMatcher,
              attribute,
              case_sensitivity_strategy
            )
          end
        end

        def should_validate_case_sensitivity?
          case_sensitivity_strategy != :ignore &&
            current_value_from_existing_record.respond_to?(:swapcase) &&
            !current_value_from_existing_record.empty?
        end

        def inspected_expected_scope_attributes
          expected_scope_attributes.map(&:inspect).to_sentence
        end

        def add_submatchers_to_test_scopes
          if should_test_scopes?
            scopes.each do |scope|
              add_submatcher(ScopeMatcher, attribute, scope)
            end
          end
        end

        def should_test_scopes?
          !expected_scope_attributes.empty? &&
            !all_scope_attributes_are_booleans?
        end

        def all_scope_attributes_are_booleans?
          options[:scopes].all? do |scope|
            all_records.map(&scope).all? { |s| boolean_value?(s) }
          end
        end

        def scopes
          expected_scope_attributes.map do |scope_attribute|
            previous_value = all_records.map(&scope_attribute).compact.max

            next_value =
              if previous_value.blank?
                dummy_value_for(scope_attribute)
              else
                next_value_for(scope_attribute, previous_value)
              end

            existing_value =
              original_values_for_existing_record.fetch(scope_attribute)

            {
              attribute: scope_attribute,
              existing_value: existing_value,
              next_value: next_value,
            }
          end
        end

        def actual_uniqueness_validations
          model._validators[attribute].select do |validator|
            validator.is_a?(::ActiveRecord::Validations::UniquenessValidator)
          end
        end

        def all_records
          @_all_records ||= model.all
        end

        def dummy_value_for(scope)
          column = column_for(scope)

          if column.respond_to?(:array) && column.array
            [dummy_scalar_value_for(column)]
          else
            dummy_scalar_value_for(column)
          end
        end

        def dummy_scalar_value_for(column)
          Shoulda::Matchers::Util.dummy_value_for(column.type)
        end

        def next_value_for(scope, previous_value)
          if previous_value.is_a?(Array)
            [next_scalar_value_for(scope, previous_value[0])]
          else
            next_scalar_value_for(scope, previous_value)
          end
        end

        def next_scalar_value_for(scope, previous_value)
          column = column_for(scope)

          if column.type == :uuid
            SecureRandom.uuid
          elsif defined_as_enum?(scope)
            available_values = available_enum_values_for(scope, previous_value)
            available_values.keys.last
          elsif polymorphic_type_attribute?(scope, previous_value)
            Uniqueness::TestModels.create(previous_value).to_s
          elsif previous_value.respond_to?(:next)
            previous_value.next
          elsif previous_value.respond_to?(:to_datetime)
            previous_value.to_datetime.next
          elsif boolean_value?(previous_value)
            !previous_value
          else
            previous_value.to_s.next
          end
        end

        def defined_as_enum?(scope)
          model.respond_to?(:defined_enums) &&
            new_record.defined_enums[scope.to_s]
        end

        def available_enum_values_for(scope, previous_value)
          new_record.defined_enums[scope.to_s].reject do |key, _|
            key == previous_value
          end
        end

        def polymorphic_type_attribute?(scope, previous_value)
          scope.to_s =~ /_type$/ && model_class?(previous_value)
        end

        def model_class?(model_name)
          model_name.constantize.ancestors.include?(::ActiveRecord::Base)
        rescue NameError
          false
        end

        def boolean_value?(value)
          [true, false].include?(value)
        end

        class HaveScopesMatcher
          def initialize(
            attribute,
            expected_scope_attributes,
            actual_uniqueness_validations
          )
            @attribute = attribute
            @expected_scope_attributes = expected_scope_attributes
            @actual_uniqueness_validations = actual_uniqueness_validations
          end

          def matches?(record)
            @record = record

            actual_uniqueness_validations.any? && (
              has_matching_absence_of_scopes? ||
              has_matching_scopes?
            )
          end

          def expectation_description
            description =
              "Expected #{model} to have a uniqueness validation on " +
              ":#{attribute} "

            if expected_scope_attributes.empty?
              description << 'with no scopes'
            else
              description << 'scoped to '
              description << inspected_expected_scope_attributes
            end

            description << '.'

            description
          end

          def aberration_description
            if actual_uniqueness_validations.any?
              description = ":#{attribute} has uniqueness validations " +
                'on it, but '

              if actual_sets_of_scope_attributes.empty?
                description << 'none of them have scopes on them.'
              else
                description << "they have these scopes instead:\n\n"

                actual_sets_of_scope_attributes.each do |set_of_scopes|
                  description << "* #{set_of_scopes.join(', ')}\n"
                end
              end

              description
            else
              "However, :#{attribute} does not have any uniqueness " +
              'validations on it at all.'
            end
          end

          private

          attr_reader :attribute, :expected_scope_attributes,
            :actual_uniqueness_validations, :record

          def has_matching_absence_of_scopes?
            actual_sets_of_scope_attributes.empty? &&
              expected_scope_attributes.empty?
          end

          def has_matching_scopes?
            actual_sets_of_scope_attributes.any? do |scopes|
              scopes == expected_scope_attributes
            end
          end

          def inspected_expected_scope_attributes
            expected_scope_attributes.map(&:inspect).to_sentence
          end

          def actual_sets_of_scope_attributes
            actual_uniqueness_validations.
              map { |validation| Array.wrap(validation.options[:scope]) }.
              select(&:present?)
          end

          def model
            record.class
          end
        end

        # TODO: We need this not to execute if the previous HaveScopesMatcher
        # failed. In other words, all of the matchers in this file are actually
        # "serial" and not "parallel". How do we accomplish this? Do we add some
        # kind of status thing to ValidationMatcher? Or do we just fold all of
        # the matchers back into a megaclass and then have an ultra-long failure
        # message method?
        class HaveUniqueAttribute < ValidationMatcherWithExistingRecord
          delegate :include_attribute_changed_value_message?,
            to: :submatcher

          def initialize(attribute, actual_uniqueness_validations, *rest)
            super(attribute, *rest)
            @actual_uniqueness_validations = actual_uniqueness_validations
          end

          def expectation_description
            "Expected :#{attribute} to only allow unique values."
          end

          def active?
            actual_uniqueness_validations.any?
          end

          def failure_message_as_submatcher
            submatcher_message =
              if submatcher.was_negated?
                submatcher.failure_message_when_negated
              else
                submatcher.failure_message
              end

            "Expected :#{attribute} to be a unique attribute: " +
              submatcher_message
          end

          protected

          def add_submatchers
            add_submatcher(submatcher)
          end

          private

          attr_reader :actual_uniqueness_validations

          def submatcher
            @_submatcher ||= disallow_value_matcher(
              current_value_from_existing_record
            )
          end
        end

        class CaseSensitivityMatcher < ValidationMatcherWithExistingRecord
          include Helpers

          def initialize(
            attribute,
            case_sensitivity_strategy,
            actual_uniqueness_validations
          )
            super(attribute)

            @case_sensitivity_strategy = case_sensitivity_strategy
            @actual_uniqueness_validations = actual_uniqueness_validations
          end

          def active?
            actual_uniqueness_validations.any?
          end

          def before_match
            super

            # if current_value_from_existing_record.blank?
              # update_existing_record!(arbitrary_non_blank_value)
            # end

            value = current_value_from_existing_record
            @swapcased_value = value.swapcase

            if case_sensitivity_strategy == :sensitive && value == swapcased_value
              raise NonCaseSwappableValueError.create(
                model: model,
                attribute: attribute,
                value: value,
              )
            end
          end

          def matches?(*args)
            actual_uniqueness_validations.any? && super(*args)
          end

          def expectation_description
            description =
              "Expected #{model}'s uniqueness validation on " +
              ":#{attribute} to be "

            description <<
              if case_sensitivity_strategy == :sensitive
                'case-sensitive'
              else
                'case-insensitive'
              end

            description << '.'

            description
          end

          def aberration_description
            'However, it was not.'
          end

          protected

          def add_submatchers
            if case_sensitivity_strategy == :sensitive
              add_submatcher_allowing(swapcased_value)
            else
              add_matcher_disallowing(swapcased_value)
            end
          end

          private

          attr_reader :case_sensitivity_strategy,
            :actual_uniqueness_validations, :swapcased_value

          # @private
          class NonCaseSwappableValueError < Shoulda::Matchers::Error
            attr_accessor :model, :attribute, :value

            def message
              Shoulda::Matchers.word_wrap <<-MESSAGE
Your #{model.name} model has a uniqueness validation on :#{attribute} which is
declared to be case-sensitive, but the value the uniqueness matcher used,
#{value.inspect}, doesn't contain any alpha characters, so using it to
test the case-sensitivity part of the validation is ineffective. There are
two possible solutions for this depending on what you're trying to do here:

a) If you meant for the validation to be case-sensitive, then you need to give
   the uniqueness matcher a saved instance of #{model.name} with a value for
   :#{attribute} that contains alpha characters.

b) If you meant for the validation to be case-insensitive, then you need to
   add `case_sensitive: false` to the validation and add `case_insensitive` to
   the matcher.

For more information, please see:

http://matchers.shoulda.io/docs/v#{Shoulda::Matchers::VERSION}/file.NonCaseSwappableValueError.html
              MESSAGE
            end
          end
        end

        class ScopeMatcher < ValidationMatcherWithExistingRecord
          delegate(
            :description,
            :failure_message,
            :failure_message_when_negated,
            to: :submatcher,
          )

          def initialize(attribute, scope)
            super(attribute)
            @scope = scope
          end

          protected

          def add_submatchers
            add_submatcher_allowing(current_value_from_existing_record) do |matcher|
              matcher.before_matching do
                set_attribute_on_new_record!(
                  scope[:attribute],
                  scope[:next_value],
                )
              end

              matcher.after_matching do
                set_attribute_on_new_record!(
                  scope[:attribute],
                  scope[:previous_value],
                  remember_setting: false,
                )
              end
            end
          end

          private

          attr_reader :scope
        end

        # @private
        class ExistingRecordInvalid < Shoulda::Matchers::Error
          include Shoulda::Matchers::ActiveModel::Helpers

          attr_accessor :underlying_exception

          def message
            <<-MESSAGE.strip
validate_uniqueness_of works by matching a new record against an
existing record. If there is no existing record, it will create one
using the record you provide.

While doing this, the following error was raised:

#{Shoulda::Matchers::Util.indent(underlying_exception.message, 2)}

The best way to fix this is to provide the matcher with a record where
any required attributes are filled in with valid values beforehand.
            MESSAGE
          end
        end
      end
    end
  end
end
