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
      #     describe Post do
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
      #     describe Post do
      #       it { should validate_uniqueness_of(:title) }
      #     end
      #
      # However, running this test will fail with something like:
      #
      #     Failures:
      #
      #       1) Post should validate :title to be case-sensitively unique
      #          Failure/Error: it { should validate_uniqueness_of(:title) }
      #          ActiveRecord::StatementInvalid:
      #            SQLite3::ConstraintException: posts.content may not be NULL: INSERT INTO "posts" ("title") VALUES (?)
      #
      # This happens because `validate_uniqueness_of` tries to create a new post
      # but cannot do so because of the `content` attribute: though unrelated to
      # this test, it nevertheless needs to be filled in. The solution is to
      # build a custom Post object ahead of time with `content` filled in:
      #
      #     describe Post do
      #       describe "validations" do
      #         subject { Post.new(content: 'Here is the content') }
      #         it { should validate_uniqueness_of(:title) }
      #       end
      #     end
      #
      # Or, if you're using
      # [FactoryGirl](http://github.com/thoughtbot/factory_girl) and you have a
      # `post` factory defined which automatically fills in `content`, you can
      # say:
      #
      #     describe Post do
      #       describe "validations" do
      #         subject { FactoryGirl.build(:post) }
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
      #     describe Post do
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
      #     describe Post do
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
      #     describe Post do
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
      #     describe Post do
      #       it { should validate_uniqueness_of(:key).case_insensitive }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class PostTest < ActiveSupport::TestCase
      #       should validate_uniqueness_of(:key).case_insensitive
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
      #     describe Post do
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
      #     describe Post do
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
      class ValidateUniquenessOfMatcher < ActiveModel::ValidationMatcher
        include ActiveModel::Helpers

        def initialize(attribute)
          super(attribute)
          @expected_message = :taken
          @options = {}
          @existing_record = nil
          @existing_record_created = false
          @original_existing_value = nil
          @failure_reason = nil
          @failure_reason_when_negated = nil
        end

        def scoped_to(*scopes)
          @options[:scopes] = [*scopes].flatten
          self
        end

        def case_insensitive
          @options[:case_insensitive] = true
          self
        end

        def allow_nil
          @options[:allow_nil] = true
          self
        end

        def expects_to_allow_nil?
          @options[:allow_nil]
        end

        def allow_blank
          @options[:allow_blank] = true
          self
        end

        def expects_to_allow_blank?
          @options[:allow_blank]
        end

        def simple_description
          description = "validate that :#{@attribute} is"

          if @options[:case_insensitive]
            description << ' case-insensitively'
          else
            description << ' case-sensitively'
          end

          description << ' unique'

          if @options[:scopes].present?
            description << " within the scope of #{inspected_expected_scopes}"
          end

          description
        end

        def matches?(given_record)
          @given_record = given_record
          @all_records = model.all

          existing_record_valid? &&
            validate_scopes_present? &&
            scopes_match? &&
            validate_everything_except_duplicate_nils_or_blanks? &&
            validate_case_sensitivity? &&
            validate_after_scope_change? &&
            allows_nil? &&
            allows_blank?
        ensure
          Uniqueness::TestModels.remove_all
        end

        protected

        def failure_reason
          @failure_reason || super
        end

        def failure_reason_when_negated
          @failure_reason_when_negated || super
        end

        def build_allow_or_disallow_value_matcher(args)
          super.tap do |matcher|
            matcher.failure_message_preface = method(:failure_message_preface)
          end
        end

        private

        def new_record
          @_new_record ||= build_new_record
        end
        alias_method :subject, :new_record

        def validation
          model._validators[@attribute].detect do |validator|
            validator.is_a?(::ActiveRecord::Validations::UniquenessValidator)
          end
        end

        def scopes_match?
          if expected_scopes == actual_scopes
            true
          else
            @failure_reason = 'Expected the validation'

            if expected_scopes.empty?
              @failure_reason << ' not to be scoped to anything'
            else
              @failure_reason << " to be scoped to #{inspected_expected_scopes}"
            end

            if actual_scopes.empty?
              @failure_reason << ', but it was not scoped to anything.'
            else
              @failure_reason << ', but it was scoped to '
              @failure_reason << "#{inspected_actual_scopes} instead."
            end

            false
          end
        end

        def expected_scopes
          Array.wrap(@options[:scopes])
        end

        def inspected_expected_scopes
          expected_scopes.map(&:inspect).to_sentence
        end

        def actual_scopes
          if validation
            Array.wrap(validation.options[:scope])
          else
            []
          end
        end

        def inspected_actual_scopes
          actual_scopes.map(&:inspect).to_sentence
        end

        def allows_nil?
          if expects_to_allow_nil?
            update_existing_record(nil)
            allows_value_of(nil, @expected_message)
          else
            true
          end
        end

        def allows_blank?
          if expects_to_allow_blank?
            update_existing_record('')
            allows_value_of('', @expected_message)
          else
            true
          end
        end

        def existing_record_valid?
          if existing_record.valid?
            true
          else
            @failure_reason =
              "Given record could not be set to #{value.inspect}: " +
              existing_record.errors.full_messages
            false
          end
        end

        def existing_record
          @existing_record ||= find_or_create_existing_record
        end

        def find_or_create_existing_record
          if find_existing_record
            find_existing_record
          else
            create_existing_record.tap do |existing_record|
              @existing_record_created = true
            end
          end
        end

        def find_existing_record
          record = model.first

          if valid_existing_record?(record)
            record.tap do |existing_record|
              @original_existing_value = existing_record.public_send(@attribute)
            end
          else
            nil
          end
        end

        def valid_existing_record?(record)
          record.present? &&
            record_has_nil_when_required?(record) &&
            record_has_blank_when_required?(record)
        end

        def record_has_nil_when_required?(record)
          !expects_to_allow_nil? || record.public_send(@attribute).nil?
        end

        def record_has_blank_when_required?(record)
          !expects_to_allow_blank? ||
            record.public_send(@attribute).to_s.strip.empty?
        end

        def create_existing_record
          @given_record.tap do |existing_record|
            @original_existing_value = value = arbitrary_non_blank_value
            existing_record.public_send("#{@attribute}=", value)
            ensure_secure_password_set(existing_record)
            existing_record.save
          end
        end

        def update_existing_record(value)
          existing_record.update_column(attribute, value)
        end

        def ensure_secure_password_set(instance)
          if has_secure_password?
            instance.password = "password"
            instance.password_confirmation = "password"
          end
        end

        def arbitrary_non_blank_value
          limit = column_limit_for(@attribute)
          non_blank_value = 'an arbitrary value'

          if limit && limit < non_blank_value.length
            'x' * limit
          else
            non_blank_value
          end
        end

        def has_secure_password?
          model.ancestors.map(&:to_s).include?(
            'ActiveModel::SecurePassword::InstanceMethodsOnActivation'
          )
        end

        def build_new_record
          existing_record.dup.tap do |new_record|
            new_record.public_send("#{@attribute}=", existing_value)

            expected_scopes.each do |scope|
              new_record.public_send(
                "#{scope}=",
                existing_record.public_send(scope)
              )
            end
          end
        end

        def validate_scopes_present?
          if all_scopes_present_on_model?
            true
          else
            reason = ''

            reason << inspected_missing_scopes.to_sentence

            if inspected_missing_scopes.many?
              reason << " do not seem to be attributes"
            else
              reason << " does not seem to be an attribute"
            end

            reason << " on #{model.name}."

            @failure_reason = reason

            false
          end
        end

        def all_scopes_present_on_model?
          missing_scopes.none?
        end

        def missing_scopes
          @_missing_scopes ||= expected_scopes.select do |scope|
            !@given_record.respond_to?("#{scope}=")
          end
        end

        def inspected_missing_scopes
          missing_scopes.map(&:inspect)
        end

        def validate_everything_except_duplicate_nils_or_blanks?
          if existing_value.nil? || (expects_to_allow_blank? && existing_value.blank?)
            update_existing_record(arbitrary_non_blank_value)
          end

          disallows_value_of(existing_value, @expected_message)
        end

        def validate_case_sensitivity?
          value = existing_value

          if value.respond_to?(:swapcase) && !value.empty?
            swapcased_value = value.swapcase

            if @options[:case_insensitive]
              disallows_value_of(swapcased_value, @expected_message)
            else
              if value == swapcased_value
                raise NonCaseSwappableValueError.create(
                  model: model,
                  attribute: @attribute,
                  value: value
                )
              end

              allows_value_of(swapcased_value, @expected_message)
            end
          else
            true
          end
        end

        def model_class?(model_name)
          model_name.constantize.ancestors.include?(::ActiveRecord::Base)
        rescue NameError
          false
        end

        def validate_after_scope_change?
          if expected_scopes.empty? || all_scopes_are_booleans?
            true
          else
            expected_scopes.all? do |scope|
              previous_value = @all_records.map(&scope).compact.max

              next_value =
                if previous_value.blank?
                  dummy_value_for(scope)
                else
                  next_value_for(scope, previous_value)
                end

              new_record.public_send("#{scope}=", next_value)

              if allows_value_of(existing_value, @expected_message)
                new_record.public_send("#{scope}=", previous_value)
                true
              else
                false
              end
            end
          end
        end

        def dummy_value_for(scope)
          column = column_for(scope)

          if column.respond_to?(:array) && column.array
            [ dummy_scalar_value_for(column) ]
          else
            dummy_scalar_value_for(column)
          end
        end

        def dummy_scalar_value_for(column)
          case column.type
          when :integer
            0
          when :date
            Date.today
          when :datetime
            DateTime.now
          when :uuid
            SecureRandom.uuid
          when :boolean
            true
          else
            'dummy value'
          end
        end

        def next_value_for(scope, previous_value)
          if previous_value.is_a?(Array)
            [ next_scalar_value_for(scope, previous_value[0]) ]
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

        def all_scopes_are_booleans?
          @options[:scopes].all? do |scope|
            @all_records.map(&scope).all? { |s| boolean_value?(s) }
          end
        end

        def boolean_value?(value)
          value.in?([true, false])
        end

        def defined_as_enum?(scope)
          model.respond_to?(:defined_enums) &&
            new_record.defined_enums[scope.to_s]
        end

        def polymorphic_type_attribute?(scope, previous_value)
          scope.to_s =~ /_type$/ && model_class?(previous_value)
        end

        def available_enum_values_for(scope, previous_value)
          new_record.defined_enums[scope.to_s].reject do |key, _|
            key == previous_value
          end
        end

        def existing_value
          existing_record.public_send(@attribute)
        end

        def model
          @given_record.class
        end

        def column_for(scope)
          model.columns_hash[scope.to_s]
        end

        def column_limit_for(attribute)
          column_for(attribute).try(:limit)
        end

        def failure_message_preface
          prefix = ''

          if @existing_record_created
            prefix << "After taking the given #{model.name},"
            prefix << " setting its :#{attribute} to "
            prefix << Shoulda::Matchers::Util.inspect_value(existing_value)
            prefix << ", and saving it as the existing record,"
            prefix << " then"
          elsif @original_existing_value != existing_value
            prefix << "Given an existing #{model.name},"
            prefix << " after setting its :#{attribute} to "
            prefix << Shoulda::Matchers::Util.inspect_value(existing_value)
            prefix << ", then"
          else
            prefix << "Given an existing #{model.name} whose :#{attribute}"
            prefix << " is "
            prefix << Shoulda::Matchers::Util.inspect_value(existing_value)
            prefix << ", after"
          end

          prefix << " making a new #{model.name} and setting its"
          prefix << " :#{attribute} to "

          if last_value_set_on_new_record == existing_value
            prefix << Shoulda::Matchers::Util.inspect_value(
              last_value_set_on_new_record
            )
            prefix << " as well"
          else
            prefix << " a different value, "
            prefix << Shoulda::Matchers::Util.inspect_value(
              last_value_set_on_new_record
            )
          end

          prefix << ", the matcher expected the new #{model.name} to be"

          prefix
        end

        def last_value_set_on_new_record
          last_submatcher_run.last_value_set
        end

        # @private
        class NonCaseSwappableValueError < Shoulda::Matchers::Error
          attr_accessor :model, :attribute, :value

          def message
            Shoulda::Matchers.word_wrap <<-MESSAGE
Your #{model.name} model has a uniqueness validation on :#{attribute} which is
declared to be case-sensitive, but the value the uniqueness matcher used,
#{value.inspect}, doesn't contain any alpha characters, so using it to
to test the case-sensitivity part of the validation is ineffective. There are
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
