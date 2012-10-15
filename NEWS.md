# v1.4.1
* Fixes an issue when used with Test::Unit on the allow value matcher.

* Fixes an issue with using ensure_inclusion_of(:attr) given an array of true or false values.

# v1.4.0

* Added `strict` option to validation matchers.

* Verify that arguments to `set_the_flash` matcher are valid.

* Fix issue in ValidateUniquenessMatcher that could cause an error on postgres.

* You can now pass an array to `ensure_exclusion_of` using `in_array`.

* Allow testing of :foreign_key option for has_one relationships using the association matcher.

* Fix bug where `ensure_length_of` would pass if the given string was too long.

* `allow_blank` will now allow values such as: ' ', '\n', and '\r'.

* Test outside values for `ensure_inclusion_of` when given an array.

* Fixed the output of the set_the_flash matcher.

# v1.3.0

* `validate_format_of` will accept `allow_blank(bool)` and `allow_nil(bool)`

* Prefer Test::Unit to Minitest when loading integrations so that RubyMine is
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

* Added `only_integer` option to `validate_numericality_of`:
  `should validate_numericality_of(:attribute).only_integer`

* Added a `query_the_database` matcher:

    `it { should query_the_database(4.times).when_calling(:complicated_method) }`
    `it { should query_the_database(4.times).or_less.when_calling(:complicated_method) }`
    `it { should_not query_the_database.when_calling(:complicated_method) }`

* Database columns are now correctly checked for primality. E.G., this works
  now: `it { should have_db_column(:id).with_options(:primary => true) }`

* The flash matcher can check specific flash keys using [], like so:
  `it { should set_the_flash[:alert].to("Password doesn't match") }`

* The `have_sent_email` matcher can check `reply_to`:
  ` it { should have_sent_email.reply_to([user, other]) }`

* Added `validates_confirmation_of` matcher:
  `it { should validate_confirmation_of(:password) }`

* Added `serialize` matcher:
  `it { should serialize(:details).as(Hash).as_instance_of(Hash) }`

* shoulda-matchers checks for all possible I18n keys, instead of just
  e.g. `activerecord.errors.messages.blank`

* Add `accept_nested_attributes` matcher

* Our very first dependency: ActiveSupport &gt;= 3.0.0
