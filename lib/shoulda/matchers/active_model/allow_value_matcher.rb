module Shoulda
  module Matchers
    module ActiveModel
      # The `allow_value` matcher (or its alias, `allow_values`) is used to
      # ensure that an attribute is valid or invalid if set to one or more
      # values.
      #
      # Take this model for example:
      #
      #     class UserProfile
      #       include ActiveModel::Model
      #       attr_accessor :website_url
      #
      #       validates_format_of :website_url, with: URI.regexp
      #     end
      #
      # You can use `allow_value` to test one value at a time:
      #
      #     # RSpec
      #     RSpec.describe UserProfile, type: :model do
      #       it { should allow_value('http://foo.com').for(:website_url) }
      #       it { should allow_value('http://bar.com').for(:website_url) }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class UserProfileTest < ActiveSupport::TestCase
      #       should allow_value('http://foo.com').for(:website_url)
      #       should allow_value('http://bar.com').for(:website_url)
      #     end
      #
      # You can also test multiple values in one go, if you like. In the
      # positive sense, this makes an assertion that none of the values cause the
      # record to be invalid. In the negative sense, this makes an assertion
      # that none of the values cause the record to be valid:
      #
      #     # RSpec
      #     RSpec.describe UserProfile, type: :model do
      #       it do
      #         should allow_values('http://foo.com', 'http://bar.com').
      #           for(:website_url)
      #       end
      #
      #       it do
      #         should_not allow_values('http://foo.com', 'buz').
      #           for(:website_url)
      #       end
      #     end
      #
      #     # Minitest (Shoulda)
      #     class UserProfileTest < ActiveSupport::TestCase
      #       should allow_values('http://foo.com', 'http://bar.com/baz').
      #         for(:website_url)
      #
      #       should_not allow_values('http://foo.com', 'buz').
      #         for(:website_url)
      #     end
      #
      # #### Caveats
      #
      # When using `allow_value` or any matchers that depend on it, you may
      # encounter an AttributeChangedValueError. This exception is raised if the
      # matcher, in attempting to set a value on the attribute, detects that
      # the value set is different from the value that the attribute returns
      # upon reading it back.
      #
      # This usually happens if the writer method (`foo=`, `bar=`, etc.) for
      # that attribute has custom logic to ignore certain incoming values or
      # change them in any way. Here are three examples we've seen:
      #
      # * You're attempting to assert that an attribute should not allow nil,
      #   yet the attribute's writer method contains a conditional to do nothing
      #   if the attribute is set to nil:
      #
      #         class Foo
      #           include ActiveModel::Model
      #
      #           attr_reader :bar
      #
      #           def bar=(value)
      #             return if value.nil?
      #             @bar = value
      #           end
      #         end
      #
      #         RSpec.describe Foo, type: :model do
      #           it do
      #             foo = Foo.new
      #             foo.bar = "baz"
      #             # This will raise an AttributeChangedValueError since `foo.bar` is now "123"
      #             expect(foo).not_to allow_value(nil).for(:bar)
      #           end
      #         end
      #
      # * You're attempting to assert that a numeric attribute should not allow
      #   a string that contains non-numeric characters, yet the writer method
      #   for that attribute strips out non-numeric characters:
      #
      #         class Foo
      #           include ActiveModel::Model
      #
      #           attr_reader :bar
      #
      #           def bar=(value)
      #             @bar = value.gsub(/\D+/, '')
      #           end
      #         end
      #
      #         RSpec.describe Foo, type: :model do
      #           it do
      #             foo = Foo.new
      #             # This will raise an AttributeChangedValueError since `foo.bar` is now "123"
      #             expect(foo).not_to allow_value("abc123").for(:bar)
      #           end
      #         end
      #
      # * You're passing a value to `allow_value` that the model typecasts into
      #   another value:
      #
      #         RSpec.describe Foo, type: :model do
      #           # Assume that `attr` is a string
      #           # This will raise an AttributeChangedValueError since `attr` typecasts `[]` to `"[]"`
      #           it { should_not allow_value([]).for(:attr) }
      #         end
      #
      # Fortunately, if you understand why this is happening, and wish to get
      # around this exception, it is possible to do so. You can use the
      # `ignoring_interference_by_writer` qualifier like so:
      #
      #         it do
      #           should_not allow_value([]).
      #             for(:attr).
      #             ignoring_interference_by_writer
      #         end
      #
      # Please note, however, that this qualifier won't magically cause your
      # test to pass. It may just so happen that the final value that ends up
      # being set causes the model to fail validation. In that case, you'll have
      # to figure out what to do. You may need to write your own test, or
      # perhaps even remove your test altogether.
      #
      # #### Qualifiers
      #
      # ##### on
      #
      # Use `on` if your validation applies only under a certain context.
      #
      #     class UserProfile
      #       include ActiveModel::Model
      #       attr_accessor :birthday_as_string
      #
      #       validates_format_of :birthday_as_string,
      #         with: /^(\d+)-(\d+)-(\d+)$/,
      #         on: :create
      #     end
      #
      #     # RSpec
      #     RSpec.describe UserProfile, type: :model do
      #       it do
      #         should allow_value('2013-01-01').
      #           for(:birthday_as_string).
      #           on(:create)
      #       end
      #     end
      #
      #     # Minitest (Shoulda)
      #     class UserProfileTest < ActiveSupport::TestCase
      #       should allow_value('2013-01-01').
      #         for(:birthday_as_string).
      #         on(:create)
      #     end
      #
      # ##### with_message
      #
      # Use `with_message` if you are using a custom validation message.
      #
      #     class UserProfile
      #       include ActiveModel::Model
      #       attr_accessor :state
      #
      #       validates_format_of :state,
      #         with: /^(open|closed)$/,
      #         message: 'State must be open or closed'
      #     end
      #
      #     # RSpec
      #     RSpec.describe UserProfile, type: :model do
      #       it do
      #         should allow_value('open', 'closed').
      #           for(:state).
      #           with_message('State must be open or closed')
      #       end
      #     end
      #
      #     # Minitest (Shoulda)
      #     class UserProfileTest < ActiveSupport::TestCase
      #       should allow_value('open', 'closed').
      #         for(:state).
      #         with_message('State must be open or closed')
      #     end
      #
      # Use `with_message` with a regexp to perform a partial match:
      #
      #     class UserProfile
      #       include ActiveModel::Model
      #       attr_accessor :state
      #
      #       validates_format_of :state,
      #         with: /^(open|closed)$/,
      #         message: 'State must be open or closed'
      #     end
      #
      #     # RSpec
      #     RSpec.describe UserProfile, type: :model do
      #       it do
      #         should allow_value('open', 'closed').
      #           for(:state).
      #           with_message(/open or closed/)
      #       end
      #     end
      #
      #     # Minitest (Shoulda)
      #     class UserProfileTest < ActiveSupport::TestCase
      #       should allow_value('open', 'closed').
      #         for(:state).
      #         with_message(/open or closed/)
      #     end
      #
      # Use `with_message` with the `:against` option if the attribute the
      # validation message is stored under is different from the attribute
      # being validated:
      #
      #     class UserProfile
      #       include ActiveModel::Model
      #       attr_accessor :sports_team
      #
      #       validate :sports_team_must_be_valid
      #
      #       private
      #
      #       def sports_team_must_be_valid
      #         if sports_team !~ /^(Broncos|Titans)$/i
      #           self.errors.add :chosen_sports_team,
      #             'Must be either a Broncos fan or a Titans fan'
      #         end
      #       end
      #     end
      #
      #     # RSpec
      #     RSpec.describe UserProfile, type: :model do
      #       it do
      #         should allow_value('Broncos', 'Titans').
      #           for(:sports_team).
      #           with_message('Must be either a Broncos or Titans fan',
      #             against: :chosen_sports_team
      #           )
      #       end
      #     end
      #
      #     # Minitest (Shoulda)
      #     class UserProfileTest < ActiveSupport::TestCase
      #       should allow_value('Broncos', 'Titans').
      #         for(:sports_team).
      #         with_message('Must be either a Broncos or Titans fan',
      #           against: :chosen_sports_team
      #         )
      #     end
      #
      # ##### ignoring_interference_by_writer
      #
      # Use `ignoring_interference_by_writer` to bypass an
      # AttributeChangedValueError that you have encountered. Please read the
      # Caveats section above for more information.
      #
      #     class Address < ActiveRecord::Base
      #       # Address has a zip_code field which is a string
      #     end
      #
      #     # RSpec
      #     RSpec.describe Address, type: :model do
      #       it do
      #         should_not allow_value([]).
      #           for(:zip_code).
      #           ignoring_interference_by_writer
      #       end
      #     end
      #
      #     # Minitest (Shoulda)
      #     class AddressTest < ActiveSupport::TestCase
      #       should_not allow_value([]).
      #         for(:zip_code).
      #         ignoring_interference_by_writer
      #     end
      #
      # @return [AllowValueMatcher]
      #
      def allow_value(*values)
        if values.empty?
          raise ArgumentError, 'need at least one argument'
        else
          AllowValueMatcher.new(*values)
        end
      end
      # @private
      alias_method :allow_values, :allow_value

      # @private
      class AllowValueMatcher < AllowOrDisallowValueMatcher
        def simple_description
          "pass validation when :#{attribute_to_set} is set to " +
            "#{inspected_values_to_set}"
        end

        def matches?(subject)
          super(subject)

          @result = run(:first_to_unexpectedly_not_pass)
          @result.nil?
        end

        # def does_not_match?(subject)
          # super(subject)

          # @result = run(:first_to_unexpectedly_not_fail)
          # @result.nil?
        # end

        def failure_message
          positive_failure_message
        end

        def failure_message_when_negated
          negative_failure_message
        end
      end
    end
  end
end
