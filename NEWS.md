# 3.1.3

### Improvements

* Update `BigDecimal.new()` to use `BigDecimal()` and avoid deprecation warnings
  in Ruby 2.6.

# 3.1.2

### Deprecations

* This is the **last version** that supports Rails 4.0 and 4.1 and Ruby 2.0 and 2.1.

### Bug fixes

* When the `permit` matcher was used without `#on`, the controller did not use
  `params#require`, the params object was duplicated, and the matcher did not
  recognize the `#permit` call inside the controller. This behavior happened
  because the matcher overwrote double registries with the same parameter hash
  whenever ActionController::Parameters was instantiated.

  * *Commit: [44c019]*
  * *Issue: [#899]*
  * *Pull request: [#902]*

# 3.1.1

### Bug fixes

* Some matchers make use of ActiveSupport's `in?` method, but do not include the
  file where this is defined in ActiveSupport. This causes problems with
  projects using shoulda-matchers that do not include all of ActiveSupport by
  default. To fix this, replace `in?` with Ruby's builtin `include?`.

  * *Pull request: [#879]*

* `validate_uniqueness_of` works by creating a record if it doesn't exist, and
  then testing against a new record with various attributes set that are equal
  to (or different than) corresponding attributes in the existing record. In
  3.1.0 a change was made whereby when the uniqueness matcher is given a new
  record and creates an existing record out of it, it ensures that the record is
  valid before continuing on. This created a problem because if the subject,
  before it was saved, was empty and therefore in an invalid state, it could not
  effectively be saved. While ideally this should be enforced, doing so would be
  a backward-incompatible change, so this behavior has been rolled back.
  ([#880], [#884], [#885])

  * *Commit: [45de869]*
  * *Issues: [#880], [#884], [#885]*

* Fix an issue with `validate_uniqueness_of` + `scoped_to` when used against a
  model where the attribute has multiple uniqueness validations and each
  validation has a different set of scopes. In this case, a test written for the
  first validation (and its scopes) would pass, but tests for the other
  validations (and their scopes) would not, as the matcher only considered the
  first set of scopes as the *actual* set of scopes.

  * *Commit: [28bd9a1]*
  * *Issues: [#830]*

### Improvements

* Update `validate_uniqueness_of` so that if an existing record fails to be
  created because a column is non-nullable and was not filled in, raise an
  ExistingRecordInvalid exception with details on how to fix the test.

  * *Commit: [78ccfc5]*

[#879]: https://github.com/thoughtbot/shoulda-matchers/issues/879
[45de869]: https://github.com/thoughtbot/shoulda-matchers/commit/45de8698487d57f559c5bf35818d1c1ee82b0e77
[#880]: https://github.com/thoughtbot/shoulda-matchers/issues/880
[#884]: https://github.com/thoughtbot/shoulda-matchers/issues/884
[#885]: https://github.com/thoughtbot/shoulda-matchers/issues/885
[78ccfc5]: https://github.com/thoughtbot/shoulda-matchers/commit/78ccfc50b52fa686c109d614df66744b0da65380
[28bd9a1]: https://github.com/thoughtbot/shoulda-matchers/commit/28bd9a10c71af4d541b692d6204163c394ebd33c
[#830]: https://github.com/thoughtbot/shoulda-matchers/issues/830

# 3.1.0

### Bug fixes

* Update `validate_numericality_of` so that submatchers are applied lazily
  instead of immediately. Previously, qualifiers were order-dependent, meaning
  that if you used `strict` before you used, say, `odd`, then `strict` wouldn't
  actually apply to `odd`. Now the order that you specify qualifiers doesn't
  matter.

  * *Source: [6c67a5e]*

* Fix `allow_value` so that it does not raise an AttributeChangedValueError
  (formerly CouldNotSetAttributeError) when used against an attribute that is an
  enum in an ActiveRecord model.

  * *Source: [9e8603e]*

* Add a `ignoring_interference_by_writer` qualifier to all matchers, not just
  `allow_value`. *This is enabled by default, which means that you should never
  get a CouldNotSetAttributeError again.* (You may get some more information if
  a test fails, however.)

  * *Source: [1189934], [5532f43]*
  * *Fixes: [#786], [#799], [#801], [#804], [#817], [#841], [#849], [#872],
    [#873], and [#874]*

* Fix `validate_numericality_of` so that it does not blow up when used against
  a virtual attribute defined in an ActiveRecord model (that is, an attribute
  that is not present in the database but is defined using `attr_accessor`).

  * *Source: [#822]*

* Update `validate_numericality_of` so that it no longer raises an
  IneffectiveTestError if used against a numeric column.

  * *Source: [5ed0362]*
  * *Fixes: [#832]*

[6c67a5e]: https://github.com/thoughtbot/shoulda-matchers/commit/6c67a5eb0df265d3a565aa7d1a7e2b645051eb5a
[9e8603e]: https://github.com/thoughtbot/shoulda-matchers/commit/9e8603eb745bfa2a5aea6dfef85adf680d447151
[1189934]: https://github.com/thoughtbot/shoulda-matchers/commit/118993480604d39c73687d069f7af3726f3e3f3e
[5532f43]: https://github.com/thoughtbot/shoulda-matchers/commit/5532f4359aa332b10de7d46f876eaffd4a95b5b6
[#786]: https://github.com/thoughtbot/shoulda-matchers/issues/786
[#799]: https://github.com/thoughtbot/shoulda-matchers/issues/799
[#801]: https://github.com/thoughtbot/shoulda-matchers/issues/801
[#804]: https://github.com/thoughtbot/shoulda-matchers/issues/804
[#817]: https://github.com/thoughtbot/shoulda-matchers/issues/817
[#841]: https://github.com/thoughtbot/shoulda-matchers/issues/841
[#849]: https://github.com/thoughtbot/shoulda-matchers/issues/849
[#872]: https://github.com/thoughtbot/shoulda-matchers/issues/872
[#873]: https://github.com/thoughtbot/shoulda-matchers/issues/873
[#874]: https://github.com/thoughtbot/shoulda-matchers/issues/874
[#822]: https://github.com/thoughtbot/shoulda-matchers/pull/822
[5ed0362]: https://github.com/thoughtbot/shoulda-matchers/commit/5ed03624197314865ff5463e473e5e84bb91d9ea
[#832]: https://github.com/thoughtbot/shoulda-matchers/issues/832

### Features

* Add a new qualifier, `ignoring_case_sensitivity`, to `validate_uniqueness_of`.
  This provides a way to test uniqueness of an attribute whose case is
  normalized, either in a custom writer method for that attribute, or in a
  custom `before_validation` callback.

  * *Source: [#840]*
  * *Fixes: [#836]*

[#840]: https://github.com/thoughtbot/shoulda-matchers/pull/840
[#836]: https://github.com/thoughtbot/shoulda-matchers/issues/836

### Improvements

* Improve failure messages and descriptions of all matchers across the board so
  that it is easier to understand what the matcher was doing when it failed.
  (You'll see a huge difference in the output of the numericality and uniqueness
  matchers in particular.)

* Matchers now raise an error if any attributes that the matcher is attempting
  to set do not exist on the model.

  * *Source: [2962112]*

* Update `validate_numericality_of` so that it doesn't always run all of the
  submatchers, but stops on the first one that fails. Since failure messages
  now contain information as to what value the matcher set on the attribute when
  it failed, this change guarantees that the correct value will be shown.

  * *Source: [8e24a6e]*

* Continue to detect if attributes change incoming values, but now instead of
  immediately seeing a CouldNotSetAttributeError, you will only be informed
  about it if the test you've written fails.

  * *Source: [1189934]*

* Add an additional check to `define_enum_for` to ensure that the column that
  underlies the enum attribute you're testing is an integer column.

  * *Source: [68dd70a]*

* Add a test for `validate_numericality_of` so that it officially supports money
  columns.

  * *Source: [a559713]*
  * *Refs: [#841]*

[2962112]: https://github.com/thoughtbot/shoulda-matchers/commit/296211211497e624dde87adae68b385ad4cdae3a
[8e24a6e]: https://github.com/thoughtbot/shoulda-matchers/commit/8e24a6e9b2b147f2c51fb03aa02543f213acab34
[68dd70a]: https://github.com/thoughtbot/shoulda-matchers/commit/68dd70a23d8997a490683adcd2108a4a5cadf8ba
[a559713]: https://github.com/thoughtbot/shoulda-matchers/commit/a559713f96303414551c0bc1767fb11eb19bcc5d

# 3.0.1

### Bug fixes

* Fix `validate_inclusion_of` + `in_array` when used against a date or datetime
  column/attribute so that it does not raise a CouldNotSetAttributeError.
  ([#783], [8fa97b4])

* Fix `validate_numericality_of` when used against a numeric column so that it
  no longer raises a CouldNotSetAttributeError if the matcher has been qualified
  in any way (`only_integer`, `greater_than`, `odd`, etc.). ([#784], [#812])

### Improvements

* `validate_uniqueness_of` now raises a NonCaseSwappableValueError if the value
  the matcher is using to test uniqueness cannot be case-swapped -- in other
  words, if it doesn't contain any alpha characters. When this is the case, the
  matcher cannot work effectively. ([#789], [ada9bd3])

[#783]: https://github.com/thoughtbot/shoulda-matchers/pull/783
[8fa97b4]: https://github.com/thoughtbot/shoulda-matchers/commit/8fa97b4ff33b57ce16dfb96be1ec892502f2aa9e
[#784]: https://github.com/thoughtbot/shoulda-matchers/pull/784
[#789]: https://github.com/thoughtbot/shoulda-matchers/pull/789
[ada9bd3]: https://github.com/thoughtbot/shoulda-matchers/commit/ada9bd3a1b9f2bb9fa74d0dfe1f8f7080314298c
[#812]: https://github.com/thoughtbot/shoulda-matchers/pull/812

# 3.0.0

### Backward-incompatible changes

* We've dropped support for Rails 3.x, Ruby 1.9.2, and Ruby 1.9.3, and RSpec 2.
  All of these have been end-of-lifed. ([a4045a1], [b7fe87a], [32c0e62])

* The gem no longer detects the test framework you're using or mixes itself into
  that framework automatically. [History][no-auto-integration-1] has
  [shown][no-auto-integration-2] that performing any kind of detection is prone
  to bugs and more complicated than it should be.

  Here are the updated instructions:

  * You no longer need to say `require: false` in your Gemfile; you can
    include the gem as normal.
  * You'll need to add the following somewhere in your `rails_helper` (for
    RSpec) or `test_helper` (for Minitest / Test::Unit):

    ``` ruby
    Shoulda::Matchers.configure do |config|
      config.integrate do |with|
        # Choose a test framework:
        with.test_framework :rspec
        with.test_framework :minitest
        with.test_framework :minitest_4
        with.test_framework :test_unit

        # Choose one or more libraries:
        with.library :active_record
        with.library :active_model
        with.library :action_controller
        # Or, choose the following (which implies all of the above):
        with.library :rails
      end
    end
    ```

  ([1900071])

* Previously, under RSpec, all of the matchers were mixed into all of the
  example groups. This created a problem because some gems, such as
  [active_model_serializers-matchers], provide matchers that share the same
  name as some of our own matchers. Now, matchers are only mixed into whichever
  example group they belong to:

    * ActiveModel and ActiveRecord matchers are available only in model example
      groups.
    * ActionController matchers are available only in controller example groups.
    * The `route` matcher is available only in routing example groups.

  ([af98a23], [8cf449b])

* There are two changes to `allow_value`:

  * The negative form of `allow_value` has been changed so that instead of
    asserting that any of the given values is an invalid value (allowing good
    values to pass through), assert that *all* values are invalid values
    (allowing good values not to pass through). This means that this test which
    formerly passed will now fail:

    ``` ruby
    expect(record).not_to allow_value('good value', *bad_values)
    ```

    ([19ce8a6])

  * `allow_value` now raises a CouldNotSetAttributeError if in setting the
    attribute, the value of the attribute from reading the attribute back is
    different from the one used to set it.

    This would happen if the writer method for that attribute has custom logic
    to ignore certain incoming values or change them in any way. Here are three
    examples we've seen:

    * You're attempting to assert that an attribute should not allow nil, yet
      the attribute's writer method contains a conditional to do nothing if
      the attribute is set to nil:

      ``` ruby
      class Foo
        include ActiveModel::Model

        attr_reader :bar

        def bar=(value)
          return if value.nil?
          @bar = value
        end
      end

      describe Foo do
        it do
          foo = Foo.new
          foo.bar = "baz"
          # This will raise a CouldNotSetAttributeError since `foo.bar` is now "123"
          expect(foo).not_to allow_value(nil).for(:bar)
        end
      end
      ```

    * You're attempting to assert that an numeric attribute should not allow a
      string that contains non-numeric characters, yet the writer method for
      that attribute strips out non-numeric characters:

      ``` ruby
      class Foo
        include ActiveModel::Model

        attr_reader :bar

        def bar=(value)
          @bar = value.gsub(/\D+/, '')
        end
      end

      describe Foo do
        it do
          foo = Foo.new
          # This will raise a CouldNotSetAttributeError since `foo.bar` is now "123"
          expect(foo).not_to allow_value("abc123").for(:bar)
        end
      end
      ```

    * You're passing a value to `allow_value` that the model typecasts into
      another value:

      ``` ruby
      describe Foo do
        # Assume that `attr` is a string
        # This will raise a CouldNotSetAttributeError since `attr` typecasts `[]` to `"[]"`
        it { should_not allow_value([]).for(:attr) }
      end
      ```

    With all of these failing examples, why are we making this change? We want
    to guard you (as the developer) from writing a test that you think acts one
    way but actually acts a different way, as this could lead to a confusing
    false positive or negative.

    If you understand the problem and wish to override this behavior so that
    you do not get a CouldNotSetAttributeError, you can add the
    `ignoring_interference_by_writer` qualifier like so. Note that this will not
    always cause the test to pass.

    ``` ruby
    it { should_not allow_value([]).for(:attr).ignoring_interference_by_writer }
    ```

    ([9d9dc4e])

* `validate_uniqueness_of` is now properly case-sensitive by default, to match
  the default behavior of the validation itself. This is a backward-incompatible
  change because this test which incorrectly passed before will now fail:

    ``` ruby
    class Product < ActiveRecord::Base
      validates_uniqueness_of :name, case_sensitive: false
    end

    describe Product do
      it { is_expected.to validate_uniqueness_of(:name) }
    end
    ```

    ([57a1922])

* `ensure_inclusion_of`, `ensure_exclusion_of`, and `ensure_length_of` have been
  removed in favor of their `validate_*` counterparts. ([55c8d09])

* `set_the_flash` and `set_session` have been changed to more closely align with
  each other:
  * `set_the_flash` has been removed in favor of `set_flash`. ([801f2c7])
  * `set_session('foo')` is no longer valid syntax, please use
    `set_session['foo']` instead. ([535fe05])
  * `set_session['key'].to(nil)` will no longer pass when the key in question
    has not been set yet. ([535fe05])

* Change `set_flash` so that `set_flash[:foo].now` is no longer valid syntax.
  You'll want to use `set_flash.now[:foo]` instead. This was changed in order to
  more closely align with how `flash.now` works when used in a controller.
  ([#755], [#752])

* Change behavior of `validate_uniqueness_of` when the matcher is not
  qualified with any scopes, but your validation is. Previously the following
  test would pass when it now fails:

  ``` ruby
  class Post < ActiveRecord::Base
    validate :slug, uniqueness: { scope: :user_id }
  end

  describe Post do
    it { should validate_uniqueness_of(:slug) }
  end
  ```

  ([6ac7b81])

[active_model_serializers-matchers]: https://github.com/adambarber/active_model_serializers-matchers
[no-auto-integration-1]: https://github.com/freerange/mocha/commit/049080c673ee3f76e76adc1e1a6122c7869f1648
[no-auto-integration-2]: https://github.com/rr/rr/issues/29
[1900071]: https://github.com/thoughtbot/shoulda-matchers/commit/190007155e0676aae84d08d8ed8eed3beebc3a06
[b7fe87a]: https://github.com/thoughtbot/shoulda-matchers/commit/b7fe87ae915f6b1f99d64e847fea536ad0f78024
[a4045a1]: https://github.com/thoughtbot/shoulda-matchers/commit/a4045a1f9bc454e618a7c55960942eb030f02fdd
[57a1922]: https://github.com/thoughtbot/shoulda-matchers/commit/57a19228b6a85f12ba7a79a26dae5869c1499c6d
[19ce8a6]: https://github.com/thoughtbot/shoulda-matchers/commit/19c38a642a2ae1316ef12540a0185cd026901e74
[eaaa2d8]: https://github.com/thoughtbot/shoulda-matchers/commit/eaaa2d83e5cd31a3ca0a1aaa65441ea1a4fffa49
[55c8d09]: https://github.com/thoughtbot/shoulda-matchers/commit/55c8d09bf2af886540924efa83c3b518d926a770
[801f2c7]: https://github.com/thoughtbot/shoulda-matchers/commit/801f2c7c1eab3b2053244485c9800f850959cfef
[535fe05]: https://github.com/thoughtbot/shoulda-matchers/commit/535fe05be8686fdafd8b22f2ed5c4192bd565d50
[6ac7b81]: https://github.com/thoughtbot/shoulda-matchers/commit/6ac7b8158cfba3b518eb3da3c24345e4473b416f
[#755]: https://github.com/thoughtbot/shoulda-matchers/pull/755
[#752]: https://github.com/thoughtbot/shoulda-matchers/pull/752
[9d9dc4e]: https://github.com/thoughtbot/shoulda-matchers/commit/9d9dc4e6b9cf2c19df66a1b4ba432ad8d3e5dded
[32c0e62]: https://github.com/thoughtbot/shoulda-matchers/commit/32c0e62596b87e37a301f87bbe21cfcc77750552
[af98a23]: https://github.com/thoughtbot/shoulda-matchers/commit/af98a23091551fb40aded5a8d4f9e5be926f53a9
[8cf449b]: https://github.com/thoughtbot/shoulda-matchers/commit/8cf449b4ca37d0d7446d2cabbfa5a1582358256d

### Bug fixes

* So far the tests for the gem have been running against only SQLite. Now they
  run against PostgreSQL, too. As a result we were able to fix some
  Postgres-related bugs, specifically around `validate_uniqueness_of`:

  * When scoped to a UUID column that ends in an "f", the matcher is able to
    generate a proper "next" value without erroring. ([#402], [#587], [#662])

  * Support scopes that are PostgreSQL array columns. Please note that this is
    only supported for Rails 4.2 and greater, as versions before this cannot
    handle array columns correctly, particularly in conjunction with the
    uniqueness validator. ([#554])

  * Fix so that when scoped to a text column and the scope is set to nil before
    running it through the matcher, the matcher does not fail. ([#521], [#607])

* Fix `define_enum_for` so that it actually tests that the attribute is present
  in the list of defined enums, as you could fool it by merely defining a class
  method that was the pluralized version of the attribute name. In the same
  vein, passing a pluralized version of the attribute name to `define_enum_for`
  would erroneously pass, and now it fails. ([#641])

* Fix `permit` so that it does not break the functionality of
  ActionController::Parameters#require. ([#648], [#675])

* Fix `validate_uniqueness_of` + `scoped_to` so that it does not raise an error
  if a record exists where the scoped attribute is nil. ([#677])

* Fix `route` matcher so if your route includes a default `format`, you can
  specify this as a symbol or string. ([#693])

* Fix `validate_uniqueness_of` so that it allows you to test against scoped
  attributes that are boolean columns. ([#457], [#694])

* Fix failure message for `validate_numericality_of` as it sometimes didn't
  provide the reason for failure. ([#699])

* Fix `shoulda/matchers/independent` so that it can be required
  independently, without having to require all of the gem. ([#746], [e0a0200])

### Features

* Add `on` qualifier to `permit`. This allows you to make an assertion that
  a restriction was placed on a slice of the `params` hash and not the entire
  `params` hash. Although we don't require you to use this qualifier, we do
  recommend it, as it's a more precise check. ([#675])

* Add `strict` qualifier to `validate_numericality_of`. ([#620])

* Add `on` qualifier to `validate_numericality_of`. ([9748869]; h/t [#356],
  [#358])

* Add `join_table` qualifier to `have_and_belong_to_many`. ([#556])

* `allow_values` is now an alias for `allow_value`. This makes more sense when
  checking against multiple values:

  ``` ruby
  it { should allow_values('this', 'and', 'that') }
  ```

  ([#692])

[9748869]: https://github.com/thoughtbot/shoulda-matchers/commit/97488690910520ed8e1f2e164b1982eff5ef1f19
[#402]: https://github.com/thoughtbot/shoulda-matchers/pull/402
[#587]: https://github.com/thoughtbot/shoulda-matchers/pull/587
[#662]: https://github.com/thoughtbot/shoulda-matchers/pull/662
[#554]: https://github.com/thoughtbot/shoulda-matchers/pull/554
[#641]: https://github.com/thoughtbot/shoulda-matchers/pull/641
[#521]: https://github.com/thoughtbot/shoulda-matchers/pull/521
[#607]: https://github.com/thoughtbot/shoulda-matchers/pull/607
[#648]: https://github.com/thoughtbot/shoulda-matchers/pull/648
[#675]: https://github.com/thoughtbot/shoulda-matchers/pull/675
[#677]: https://github.com/thoughtbot/shoulda-matchers/pull/677
[#620]: https://github.com/thoughtbot/shoulda-matchers/pull/620
[#693]: https://github.com/thoughtbot/shoulda-matchers/pull/693
[#356]: https://github.com/thoughtbot/shoulda-matchers/pull/356
[#358]: https://github.com/thoughtbot/shoulda-matchers/pull/358
[#556]: https://github.com/thoughtbot/shoulda-matchers/pull/556
[#457]: https://github.com/thoughtbot/shoulda-matchers/pull/457
[#694]: https://github.com/thoughtbot/shoulda-matchers/pull/694
[#692]: https://github.com/thoughtbot/shoulda-matchers/pull/692
[#699]: https://github.com/thoughtbot/shoulda-matchers/pull/699
[#746]: https://github.com/thoughtbot/shoulda-matchers/pull/746
[e0a0200]: https://github.com/thoughtbot/shoulda-matchers/commit/e0a0200fe47157c161fb206043540804bdad664e

# 2.8.0

### Deprecations

* `ensure_length_of` has been renamed to `validate_length_of`.
  `ensure_length_of` is deprecated and will be removed in 3.0.0.

* `set_the_flash` has been renamed to `set_flash`. `set_the_flash` is
  deprecated and will be removed in 3.0.0.

* `set_session(:foo)` is deprecated in favor of `set_session[:foo]`.
  `set_session(:foo)` will be invalid syntax in 3.0.0.

* Using `should set_session[:key].to(nil)` to assert that that a value has not
  been set is deprecated. Please use `should_not set_session[:key]` instead.
  In 3.0.0, `should set_session[:key].to(nil)` will only pass if the value is
  truly nil.

### Bug fixes

* Fix `delegate_method` so that it works again with shoulda-context. ([#591])

* Fix `validate_uniqueness_of` when used with `scoped_to` so that when one of
  the scope attributes is a polymorphic `*_type` attribute and the model has
  another validation on the same attribute, the matcher does not fail with an
  error. ([#592])

* Fix `has_many` used with `through` so that when the association does not
  exist, and the matcher fails, it does not raise an error when producing the
  failure message. ([#588])

* Fix `have_and_belong_to_many` used with `join_table` so that it does not fail
  when `foreign_key` and/or `association_foreign_key` was specified on the
  association as a symbol instead of a string. ([#584])

* Fix `allow_value` when an i18n translation key is passed to `with_message` and
  the `:against` option is used to specify an alternate attribute. A bug here
  also happened to affect `validate_confirmation_of` when an i18n translation
  key is passed to `with_message`. ([#593])

* Fix `class_name` qualifier for association matchers so that if the model being
  referenced is namespaced, the matcher will correctly resolve the class before
  checking it against the association's `class_name`. ([#537])

* Fix `validate_inclusion_of` used with `with_message` so that it fails if given
  a message that does not match the message on the validation. ([#598])

* Fix `route` matcher so that when controller and action are specified in hash
  notation (e.g. `posts#show`), route parameters such as `id` do not need to be
  specified as a string but may be specified as a number as well. ([#602])

### Features

* Add ability to test `:primary_key` option on associations. ([#597])

* Add `allow_blank` qualifier to `validate_uniqueness_of` to complement
  the `allow_blank` option. ([#543])

* Change `set_session` so that #[] and #to qualifiers are optional, similar to
  `set_flash`. That is, you can now say `should set_session` to assert that any
  flash value has been set, or `should set_session.to('value')` to assert that
  any value in the session is 'value'.

* Change `set_session` so that its #to qualifier supports regexps, similar to
  `set_flash`.

* Add `with_prefix` qualifier to `delegate_method` to correspond to the `prefix`
  option for Rails's `delegate` macro. ([#622])

* Add support for Rails 4.2, especially fixing `serialize` matcher to remove
  warning about `serialized_attributes` being deprecated. ([#627])

* Update `dependent` qualifier on association matchers to support `:destroy`,
  `:delete`, `:nullify`, `:restrict`, `:restrict_with_exception`, and
  `:restrict_with_error`. You can also pass `true` or `false` to assert that
  the association has (or has not) been declared with *any* dependent option.
  ([#631])

### Improvements

* Tweak `allow_value` failure message so that it reads a bit nicer when listing
  existing errors.

[#591]: https://github.com/thoughtbot/shoulda-matchers/pull/591
[#592]: https://github.com/thoughtbot/shoulda-matchers/pull/592
[#588]: https://github.com/thoughtbot/shoulda-matchers/pull/588
[#584]: https://github.com/thoughtbot/shoulda-matchers/pull/584
[#593]: https://github.com/thoughtbot/shoulda-matchers/pull/593
[#597]: https://github.com/thoughtbot/shoulda-matchers/pull/597
[#537]: https://github.com/thoughtbot/shoulda-matchers/pull/537
[#598]: https://github.com/thoughtbot/shoulda-matchers/pull/598
[#602]: https://github.com/thoughtbot/shoulda-matchers/pull/602
[#543]: https://github.com/thoughtbot/shoulda-matchers/pull/543
[#622]: https://github.com/thoughtbot/shoulda-matchers/pull/622
[#627]: https://github.com/thoughtbot/shoulda-matchers/pull/627
[#631]: https://github.com/thoughtbot/shoulda-matchers/pull/631

# 2.7.0

### Deprecations

* `ensure_inclusion_of` has been renamed to `validate_inclusion_of`.
  `ensure_inclusion_of` is deprecated and will be removed in 3.0.0.

* `ensure_exclusion_of` has been renamed to `validate_exclusion_of`.
  `ensure_exclusion_of` is deprecated and will be removed in 3.0.0.

### Bug fixes

* Fix `delegate_method` so that it does not raise an error if the method that
  returns the delegate object is private.

* Warn when `ensure_inclusion_of` is chained with `.in_array([false, true])`
  as well as with `.in_array([true, false])`.

* Fix `set_session` so that the `to` qualifier if given nil checks that the
  session variable in question was set to nil (previously this actually did
  nothing).

* Fix `filter_param` so that it works when `config.filter_parameters` contains
  regexes.

* Fix `delegate_method` so that it can be required independent of Active
  Support.

* Fix `validate_uniqueness_of`. When used against an unpersisted record whose
  model contained a non-nullable column other than the one being validated, the
  matcher would break. Even if the test set that column to a value beforehand,
  the record had to be persisted in order for the matcher to work. Now this is
  no longer the case and the record can remain unpersisted.

* Fix `validate_absence_of`: it required that a string be passed as the
  attribute name rather than a symbol (which is the usual and documented usage).

### Features

* Add new matcher `define_enum_for` to test usage of the `enum` macro introduced
  in Rails 4.1.

### Improvements

* `have_and_belongs_to_many` now checks to make sure that the join table
  contains the correct columns for the left- and right-hand side of the
  association.

* Reword failure message for `delegate_method` so that it's a little more
  helpful.

# 2.6.2

### Bug fixes

* If you have a Rails >= 4.1 project and you are running tests using Spring,
  matchers that depend on assertions within Rails' testing layer (e.g.
  `render_template` and `route`) will no longer fail.

* Fix `permit` so that it can be used more than once in the same test.

* Revert change to `validate_uniqueness_of` made in 2.6.0 so that it no longer
  provides default values for non-primary, non-nullable columns. This approach
  was causing test failures because it makes the assumption that none of these
  columns allow only specific values, which is not true. If you get an error
  from `validate_uniqueness_of`, your best bet continues to be creating a record
  manually and calling `validate_uniqueness_of` on that instead.

* The majority of warnings that the gem produced have been removed. The gem
  still produces warnings under Ruby 1.9.3; we will address this in a future
  release.

# 2.6.1

### Bug fixes

* Revert changes to `validate_numericality_of` made in the last release, which
  made it so that comparison qualifiers specified on the validation are tested
  using a very small decimal number offset rather than a whole number by
  default, except if the matcher was qualified with `only_integer`. This means
  that prior to 2.6.0, if your validation specified `only_integer` and you did
  not, then after 2.6.0 that test would fail. This is now fixed.

* Fix regression in previous release where ActiveRecord matchers would not be
  included when ActiveRecord wasn't defined (i.e. if you were using ActiveModel
  only).

* Revert the behavior of `allow_value` changed in 2.6.0 (it will no longer raise
  CouldNotClearAttribute). This was originally done as a part of a fix for
  `validate_presence_of` when used in conjunction with `has_secure_password`.
  That fix has been updated so that it does not affect `allow_value`.

* Fix callback matchers and correct test coverage.

* Fix `permit` so that it does not interfere with different usages of `params`
  in your controller action. Specifically, this will not raise an error:
  `params.fetch(:foo, {}).permit(:bar, :baz)` (the `permit` will have no
  problems recognizing that :bar and :baz are permitted params).

* Fix `permit` on Rails 4.1 to use PATCH by default for #update instead of PUT.
  Previously you had to specify this manually.

* Fix `permit` so that it track multiple calls to #permit in your controller
  action. Previously only the last usage of #permit would be considered in
  determining whether the matcher matched.

* Fix `permit` so that if the route for your action requires params (such as id)
  then you can now specify those params:
  `permit(:first_name, :last_name).for(:update, params: { id: 42 })`.

* Fix `delegate_method` so that it does not stub the target method forever,
  returning it to its original implementation after the match ends.

* Fix `validate_uniqueness_of` to work with Rails 4.1 enum columns.

### Features

* Teach `with_message` qualifier on `allow_value` to accept a hash of i18n
  interpolation values:
  `allow_value('foo').for(:attr).with_message(:greater_than, values: { count: 20 })`.

# 2.6.0

* The boolean argument to `have_db_index`'s `unique` option is now optional, for
  consistency with other matchers.

* Association matchers now test that the model being referred to (either
  implicitly or explicitly, using `:class_name`) actually exists.

* Add ability to test `:autosave` option on associations.

* Fix `validate_uniqueness_of(...).allow_nil` so that it can be used against an
  non-password attribute which is in a model that `has_secure_password`. Doing
  so previously would result in a "Password digest missing on new record" error.

* Fix description for `validate_numericality_of` so that if the matcher fails,
  the error message reported does not say the matcher accepts integer values if
  you didn't specify that.

* Fix `ensure_inclusion_of` so that you can use it against a boolean column
  (and pass boolean values to `in_array`). There are two caveats:

  * You should not test that your attribute allows both true and false
    (`.in_array([true, false]`); there's no way to test that it doesn't accept
    anything other than that.
  * You cannot test that your attribute allows nil (`.in_array([nil])`) if
    the column does not allow null values.

* Change `validate_uniqueness_of(...)` so that it provides default values for
  non-nullable attributes.

* Running `rake` now installs Appraisals before running the test suite.
  (Additionally, we now manage Appraisals using the `appraisal` executable in
  Appraisal 1.0.0.)

* Add `allow_nil` option to `validate_numericality_of` so that you can validate
  that numeric values are validated only if a value is supplied.

* Fix `validate_numericality_of` so that test fails when the value with
  `greater_than`, `greater_than_or_equal_to`, `less_than`, `less_than_or_equal_
  to` or `equal_to` is not appropriate.

* Change `validate_presence_of` under Rails 4 so that if you are using it with a
  user whose model `has_secure_password` and whose password is set to a value,
  you will be instructed to use a user whose password is blank instead. The
  reason for this change is due to the fact that Rails 4's version of
  `has_secure_password` defines #password= such that `nil` will be ignored,
  which interferes with how `validate_presence_of` works.

* Add ability to test `belongs_to` associations defined with `:inverse_of`.

* Add back matchers that were removed in 2.0.0: `permit`, for testing strong
  parameters, and `delegate_method`, for testing delegation.

* Add new matchers for testing controller filters: `before_filter`,
  `after_filter`, and `around_filter` (aliased to `before_action`,
  `after_action` and `around_action` for Rails 4).

* Fix `rescue_from` matcher so that it does not raise an error when testing
  a method handler which has been marked as protected or private.

* Fix compatibility issues with Rails 4.1:
  * `set_the_flash` and `have_and_belongs_to_many` no longer raise errors
  * Minitest no longer prints warnings whenever shoulda-matchers is required

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
