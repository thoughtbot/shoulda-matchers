# HEAD

# v 2.5.0

* Fix Rails/Test::Unit integration to ensure that the test case classes we are
  re-opening actually exist.

* Fix `ensure_length_of` so that it uses the right message to validate when
  `is_equal_to` is specified in conjunction with a custom message.

* The `route` matcher now accepts specifying a controller/action pair as a
  string instead of only a hash (e.g. `route(...).to('posts#index')` instead of
  `route(...).to(controller: 'posts', action: 'index')`).

* The `ensure_inclusion_of` matcher now works with a decimal column.

* Under Rails 3, if you had an association matcher chained with the
  the `order` submatcher -- e.g. `should have_many(:foos).order(:bar)` -- and
  your association had an `:include` on it, using the matcher would raise an
  error. This has been fixed.

* Fix `validate_uniqueness_of` so it doesn't fail if the attribute under
  test has a limit of fewer than 16 characters.

* You can now test that your `has_many :through` or `has_one :through`
  associations are defined with a `:source` option.

* Add new matcher `validates_absence_of`.

* Update matchers so that they use `failure_message` and
  `failure_message_when_negated` to define error messages. These are new methods
  in the upcoming RSpec 3 release which replace `failure_message_for_should` and
  `failure_message_for_should_not`. We've kept backward compatibility so all of
  your existing tests should still work -- this is just to make sure when RSpec
  3 is released you don't get a bunch of warnings.

# v 2.4.0

* Fix a bug with the `validate_numericality_of` matcher that would not allow the
  `with_message` option on certain submatchers.

* Fix a regression with context-dependent validations in ActiveResource

* shoulda-matchers is now fully compatible with Rails 4.

* When not using RSpec, shoulda-matchers is now auto-included into
  ActiveSupport::TestCase instead of Test::Unit::TestCase (in Rails 4
  the former no longer inherits from the latter).

# v 2.3.0

* Fix a bug in `ensure_inclusion_of` that would cause issues with using
  `in_array` with an integer value.

* Add support for PostgreSQL UUID columns to `validates_uniqueness_of` (#334).

* Fix `validates_numericality_of` so that `is_equal_to` submatcher works
  correctly (#326).

* Fix context support for validation matchers and disallowed values (#313).

* Add a `counter_cache` submatcher for `belongs_to` associations (#311).

* Add a `rescue_from` matcher for Rails controllers which checks that the
  correct ActiveSupport call has been made and that the handlers exist without
  actually throwing an exception (#287).

* Changed the scope of AssociationMatcher methods from protected to private.

* Extracted `#order`, `#through`, and `#dependent` from AssociationMatcher as
  their own submatchers.

# v 2.2.0

* Fix `have_and_belong_to_many` matcher issue for Rails 4.

* Fix `validate_uniqueness_of.scoped_to` issue when the scoped field is already
  taken (#207).

* Add comparison submatchers to `validate_numericality_of` to correspond to the
  comparison options you can give to `validates_numericality_of` (#244).

# v 2.1.0

* Add missing `failure_message_for_should_not` implementations to
`validate_numericality_of` and its submatchers

* Support validation contexts for testing validations `on: :create` and when
  using custom contexts like `model.valid?(:my_context)`.

* Fix a bug in validations with autosaved models.

* Fix maximum value detection for the `ensure_inclusion_of` and
`ensure_exclusion_of` matchers.

* Add `:odd` and `:even` options to the `validate_numericality_of` matcher.

* Add `:touch` option to AssociationMatcher.

* Ruby 2.0.0 is now officially supported.

* Fix the issue where using `%{attribute}` or `%{model}` in I18n translations
raised exceptions.

* Support datetime columns in `validate_uniqueness_of.scoped_to`.

* Add `allow_nil` option to the `validate_uniqueness_of` matcher.

# v 2.0.0
* Remove the following matchers:
  * `assign_to`
  * `respond_with_content_type`
  * `query_the_database`
  * `validate_format_of`
  * `have_sent_email`
  * `permit` (strong parameters matcher)
  * `delegate_method`

* For more information about 2.0 changes, see:
http://robots.thoughtbot.com/post/47031676783/shoulda-matchers-2-0.

# v 1.5.6
* Revert previous change in AllowValueMatcher that added a check for a
properly-set attribute.

# v 1.5.5
* AllowValueMatcher checks that the right value is used for attempts at
setting the attribute with it.
  * Please note that previously-passing tests might now fail. It is likely that
  it's not a bug, but please make sure that the code you're testing is written
  properly before submitting an issue.

* Use DisallowValueMatcher for `disallows_value_of` method.

* Assert `class_name` value on real class name for AssociationMatcher.

* Correct the variable used for `validate_confirmation_of` matcher description.

# v 1.5.4
* Properly-released version of 1.5.3.

# v 1.5.3 - yanked due to mis-release
* Alleviate the need to add `rspec` gem to your app.

# v 1.5.1
* Bump version dependency of Bourne to allow for Mocha upgrade.

* Should fix incompatibility with MiniTest.

# v 1.5.0
* Deprecate the following matchers:
  * `assign_to`
  * `respond_with_content_type`
  * `query_the_database`
  * `validate_format_of`
  * `have_sent_email`
  * `permit` (strong parameters matcher)
  * `delegate_method`

* Use RSpec's native `configure.include` syntax for including matchers into
  RSpec (#204).

* Do not force MiniTest loading when test-unit is available (this was fixed
  before 1.3.0 then reverted in 1.3.0).

# v1.4.2
* Add a new `delegate_method` matcher.

# v1.4.1
* Fix an issue when used with Test::Unit on the allow value matcher.

* Fix an issue with using `ensure_inclusion_of(:attr)` given an array of true or false values.

# v1.4.0

* Add `strict` option to validation matchers.

* Verify that arguments to `set_the_flash` matcher are valid.

* Fix issue in ValidateUniquenessMatcher that could cause an error on postgres.

* You can now pass an array to `ensure_exclusion_of` using `in_array`.

* Allow testing of `:foreign_key` option for `has_one` relationships using the association matcher.

* Fix bug where `ensure_length_of` would pass if the given string was too long.

* `allow_blank` will now allow values such as: ' ', '\n', and '\r'.

* Test outside values for `ensure_inclusion_of` when given an array.

* Fix the output of the `set_the_flash` matcher.

# v1.3.0

* `validate_format_of` will accept `allow_blank(bool)` and `allow_nil(bool)`.

* Prefer Test::Unit to MiniTest when loading integrations so that RubyMine is
  happy (#88).

* `validates_uniqueness_of` will now create a record if one does not exist.
  Previously, users were required to create a record in the database before
  using this matcher.

* Fix an edge case when where the matchers weren't loaded into Test::Unit when
  mixing RSpec and Test::Unit tests and also loading both the 'rspec-rails' gem
  and 'shoulda-matchers' gem from the same Gemfile group, namely [:test,
  :development].

* `controller.should_not render_partial` now correctly matches `render partial: "partial"`.

# v1.2.0

* `ensure_inclusion_of` now has an `in_array` parameter:
  `ensure_inclusion_of(:attr).in_array(['foo', 'bar'])`. It cannot be used with
  the `.in_range` option. (vpereira)

* `ensure_in_inclusion_of` with `in_array` will accept `allow_blank(bool)` and `allow_nil(false)`

* Test against Rails 3.2.

* Fix `ensure_length_of` to use all possible I18n error messages.

* `have_db_index.unique(nil)` used to function exactly the same as
  `have_db_index` with no unique option. It now functions the same as
  `have_db_index.unique(false)`.

* In 1.1.0, `have_sent_email` checked all emails to ensure they matched. It now
  checks that only one email matches, which restores 1.0.0 behavior.

# v1.1.0

* Add `only_integer` option to `validate_numericality_of`:
  `should validate_numericality_of(:attribute).only_integer`

* Add a `query_the_database` matcher:

    `it { should query_the_database(4.times).when_calling(:complicated_method) }`
    `it { should query_the_database(4.times).or_less.when_calling(:complicated_method) }`
    `it { should_not query_the_database.when_calling(:complicated_method) }`

* Database columns are now correctly checked for primality. E.G., this works
  now: `it { should have_db_column(:id).with_options(:primary => true) }`

* The flash matcher can check specific flash keys using [], like so:
  `it { should set_the_flash[:alert].to("Password doesn't match") }`

* The `have_sent_email` matcher can check `reply_to`:
  ` it { should have_sent_email.reply_to([user, other]) }`

* Add `validates_confirmation_of` matcher:
  `it { should validate_confirmation_of(:password) }`

* Add `serialize` matcher:
  `it { should serialize(:details).as(Hash).as_instance_of(Hash) }`

* shoulda-matchers checks for all possible I18n keys, instead of just
  e.g. `activerecord.errors.messages.blank`

* Add `accept_nested_attributes` matcher

* Our very first dependency: ActiveSupport &gt;= 3.0.0
