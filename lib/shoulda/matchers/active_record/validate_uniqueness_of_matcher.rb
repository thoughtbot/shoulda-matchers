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

        def matches?(subject)
          Uniqueness::TestModels.within_sandbox { super(subject) }
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
          add_submatcher_to_verify_validation_has_scopes
          add_submatcher_to_verify_model_has_attribute_and_scope_attributes
          add_submatcher_to_test_uniqueness_of_non_blank_value
          add_submatcher_to_test_case_sensitivity
          add_submatchers_to_test_scopes
          add_submatcher_for_allow_nil
          add_submatcher_for_allow_blank
        end

        private

        attr_reader :options

        def expected_scope_attributes
          options[:scopes]
        end

        def case_sensitivity_strategy
          options[:case_sensitivity_strategy]
        end

        def subject
          unless defined?(@_subject)
            initialize_subject
          end

          @_subject
        end

        def initialize_subject
          @_subject = existing_record.dup

          attribute_names_under_test.each do |attribute_name|
            set_attribute_on_new_record!(
              attribute_name,
              existing_record.public_send(attribute_name),
            )
          end

          subject
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

        def add_submatcher_for_allow_nil
          if expects_to_allow_nil?
            add_submatching_allowing(nil) do |matcher|
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

        def add_submatcher_to_verify_validation_has_scopes
          submatcher = HaveScopesMatcher.new(
            self,
            attribute,
            expected_scope_attributes,
          )
          add_submatcher(submatcher)
        end

        def add_submatcher_to_verify_model_has_attribute_and_scope_attributes
          ([attribute] + expected_scope_attributes).each do |attr|
            submatcher =
              Shoulda::Matchers::ActiveModel::HaveAttributeMatcher.new(attr)
            add_submatcher(submatcher)
          end
        end

        def add_submatcher_to_test_uniqueness_of_non_blank_value
          add_submatcher_disallowing(value_from_existing_record) do |matcher|
            matcher.before_matching do
              if value_from_existing_record.blank?
                update_existing_record!(arbitrary_non_blank_value)
              end
            end
          end
        end

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

        def add_submatcher_to_test_case_sensitivity
          if should_validate_case_sensitivity?
            submatcher = CaseSensitivityMatcher.new(
              self,
              attribute,
            )
            add_submatcher(submatcher)
          end
        end

        def should_validate_case_sensitivity?
          case_sensitivity_strategy != :ignore &&
            value_from_existing_record.respond_to?(:swapcase) &&
            !value_from_existing_record.empty?
        end

        def add_submatchers_to_test_scopes
          if should_test_scopes?
            scopes.each do |scope|
              add_submatcher_allowing(value_from_existing_record) do |matcher|
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
                  )
                end
              end
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
            previous_value = all_records.map(&scope).compact.max

            next_value =
              if previous_value.blank?
                dummy_value_for(scope)
              else
                next_value_for(scope, previous_value)
              end

            {
              attribute: scope_attribute,
              existing_value: existing_value,
              next_value: next_value,
            }
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

        def column_for(scope)
          model.columns_hash[scope.to_s]
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
          def initialize(parent_matcher, attribute, expected_scope_attributes)
            @parent_matcher = parent_matcher
            @attribute = attribute
            @expected_scope_attributes = expected_scope_attributes
          end

          def matches?(subject)
            @subject = subject
            no_scopes? || scopes_match?
          end

          def failure_message
            "Expected #{model} to #{expectation}. However, #{aberration}."
          end

          private

          attr_reader :parent_matcher, :attribute, :expected_scope_attributes,
            :subject

          def no_scopes?
            actual_sets_of_scope_attributes.empty? &&
              expected_scope_attributes.empty?
          end

          def scopes_match?
            actual_sets_of_scope_attributes.any? do |scopes|
              scopes == expected_scope_attributes
            end
          end

          def expectation
            expectation = "have a uniqueness validation on :#{attribute}"

            if expected_scope_attributes.empty?
              expectation << 'which is not scoped to anything'
            else
              expectation << 'which is scoped to '
              expectation << inspected_expected_scope_attributes
            end

            expectation
          end

          def aberration
            if actual_sets_of_scope_attributes.empty?
              'no existing validations had scopes on them'
            else
              aberration =
                "the existing validations had these scopes instead:\n\n"

              actual_sets_of_scope_attributes.each do |set_of_scopes|
                aberration << "* #{set_of_scopes.join(', ')}\n"
              end

              aberration
            end
          end

          def inspected_expected_scope_attributes
            expected_scope_attributes.map(&:inspect).to_sentence
          end

          def actual_sets_of_scope_attributes
            actual_validations.
              map { |validation| Array.wrap(validation.options[:scope]) }.
              select(&:present?)
          end

          def actual_validations
            model._validators[attribute].select do |validator|
              validator.is_a?(::ActiveRecord::Validations::UniquenessValidator)
            end
          end
        end

        class CaseSensitivityMatcher < ValidationMatcherWithExistingRecord
          def before_match
            if value_from_existing_record.blank?
              update_existing_record!(arbitrary_non_blank_value)
            end

            value = value_from_existing_record
            @swapcased_value = value.swapcase

            if case_sensitivity_strategy == :sensitive && value == swapcased_value
              raise NonCaseSwappableValueError.create(
                model: model,
                attribute: attribute,
                value: value,
              )
            end
          end

          def simple_description
          end

          def expectation
          end

          def aberration
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

          attr_reader :swapcased_value

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
      end
    end
  end
end
