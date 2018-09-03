# Shoulda Matchers [![Gem Version][version-badge]][rubygems] [![Build Status][travis-badge]][travis] ![Downloads][downloads-badge] [![Hound][hound-badge]][hound]

[![shoulda-matchers][logo]][website]

Shoulda Matchers provides RSpec- and Minitest-compatible one-liners that test
common Rails functionality. These tests would otherwise be much longer, more
complex, and error-prone.

* [Documentation](#documentation)
* [Compatibility](#compatibility)
* [Getting started](#getting-started)
   * [RSpec](#rspec)
      * [Availability of matchers in various example groups](#availability-of-matchers-in-various-example-groups)
      * [<code>should</code> vs <code>is_expected.to</code>](#should-vs-is_expectedto)
   * [Minitest](#minitest)
* [Matchers](#matchers)
   * [ActiveModel matchers](#activemodel-matchers)
   * [ActiveRecord matchers](#activerecord-matchers)
   * [ActionController matchers](#actioncontroller-matchers)
   * [Independent matchers](#independent-matchers)
* [Contributing](#contributing)
* [Versioning](#versioning)
* [License](#license)
* [About thoughtbot](#about-thoughtbot)

## Documentation

[View the official documentation for the latest version (4.0.0.rc1).][rubydocs]

## Compatibility

Shoulda Matchers 4 is tested and supported against Rails 5.x, Rails 4.2, RSpec
3.x, Minitest 5, Minitest 4, and Ruby 2.2+.

For Rails 4.0/4.1 and Ruby 2.0/2.1 compatibility, please use shoulda-matchers
[3.1.2](https://github.com/thoughtbot/shoulda-matchers/releases/tag/v3.1.2).

## Getting started

### RSpec

Start by including `shoulda-matchers` in your Gemfile:

```ruby
group :test do
  gem 'shoulda-matchers', '4.0.0.rc1'
  gem 'rails-controller-testing' # If you are using Rails 5.x
end
```

Now you need to tell the gem a couple of things:

* Which test framework you're using
* Which portion of the matchers you want to use

You can supply this information by using a configuration block. Place the
following in `rails_helper.rb`:

```ruby
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
    # Or, choose all of the above:
    with.library :rails
  end
end
```

Now you can use matchers in your tests. For instance, a model test might look
like this:

```ruby
RSpec.describe Person, type: :model do
  it { should validate_presence_of(:name) }
end
```

#### Availability of matchers in various example groups

Since shoulda-matchers provides four categories of matchers, there are four
different levels where you can use these matchers:

* ActiveRecord and ActiveModel matchers are available only in model example
  groups, i.e., those tagged with `type: :model` or in files located under
  `spec/models`.
* ActionController matchers are available only in controller example groups,
  i.e., those tagged with `type: :controller` or in files located under
  `spec/controllers`.
* The `route` matcher is available also in routing example groups, i.e., those
  tagged with `type: :routing` or in files located under `spec/routing`.
* Independent matchers are available in all example groups.

**If you are using ActiveModel or ActiveRecord outside of Rails** and you want
to use model matchers in certain example groups, you'll need to manually include
them. Here's a good way of doing that:

```ruby
RSpec.configure do |config|
  config.include(Shoulda::Matchers::ActiveModel, type: :model)
  config.include(Shoulda::Matchers::ActiveRecord, type: :model)
end
```

Then you can say:

```ruby
describe MySpecialModel, type: :model do
  # ...
end
```

#### `should` vs `is_expected.to`

Note that in this README and throughout the documentation we're using the
`should` form of RSpec's one-liner syntax over `is_expected.to`. The `should`
form works regardless of how you've configured RSpec -- meaning you can still
use it even when using the `expect` syntax. But if you prefer to use
`is_expected.to`, you can do that too:

```ruby
RSpec.describe Person, type: :model do
  it { is_expected.to validate_presence_of(:name) }
end
```

### Minitest

Shoulda Matchers was originally a component of [Shoulda][shoulda], a gem that
also provides `should` and `context` syntax via
[`shoulda-context`][shoulda-context].

At the moment, `shoulda` has not been updated to support `shoulda-matchers` 3.x and 4.x,
so you'll want to add the following to your Gemfile:

```ruby
group :test do
  gem 'shoulda', '~> 3.5'
  gem 'shoulda-matchers', '~> 2.0'
end
```

Now you can use matchers in your tests. For instance a model test might look
like this:

```ruby
class PersonTest < ActiveSupport::TestCase
  should validate_presence_of(:name)
end
```

## Matchers

### ActiveModel matchers

* **[allow_value](lib/shoulda/matchers/active_model/allow_value_matcher.rb)**
  tests that an attribute is valid or invalid if set to one or more values.
  *(Aliased as #allow_values.)*
* **[have_secure_password](lib/shoulda/matchers/active_model/have_secure_password_matcher.rb)**
  tests usage of `has_secure_password`.
* **[validate_absence_of](lib/shoulda/matchers/active_model/validate_absence_of_matcher.rb)**
  tests usage of `validates_absence_of`.
* **[validate_acceptance_of](lib/shoulda/matchers/active_model/validate_acceptance_of_matcher.rb)**
  tests usage of `validates_acceptance_of`.
* **[validate_confirmation_of](lib/shoulda/matchers/active_model/validate_confirmation_of_matcher.rb)**
  tests usage of `validates_confirmation_of`.
* **[validate_exclusion_of](lib/shoulda/matchers/active_model/validate_exclusion_of_matcher.rb)**
  tests usage of `validates_exclusion_of`.
* **[validate_inclusion_of](lib/shoulda/matchers/active_model/validate_inclusion_of_matcher.rb)**
  tests usage of `validates_inclusion_of`.
* **[validate_length_of](lib/shoulda/matchers/active_model/validate_length_of_matcher.rb)**
  tests usage of `validates_length_of`.
* **[validate_numericality_of](lib/shoulda/matchers/active_model/validate_numericality_of_matcher.rb)**
  tests usage of `validates_numericality_of`.
* **[validate_presence_of](lib/shoulda/matchers/active_model/validate_presence_of_matcher.rb)**
  tests usage of `validates_presence_of`.

### ActiveRecord matchers

* **[accept_nested_attributes_for](lib/shoulda/matchers/active_record/accept_nested_attributes_for_matcher.rb)**
  tests usage of the `accepts_nested_attributes_for` macro.
* **[belong_to](lib/shoulda/matchers/active_record/association_matcher.rb)**
  tests your `belongs_to` associations.
* **[define_enum_for](lib/shoulda/matchers/active_record/define_enum_for_matcher.rb)**
  tests usage of the `enum` macro.
* **[have_and_belong_to_many](lib/shoulda/matchers/active_record/association_matcher.rb)**
  tests your `has_and_belongs_to_many` associations.
* **[have_db_column](lib/shoulda/matchers/active_record/have_db_column_matcher.rb)**
  tests that the table that backs your model has a specific column.
* **[have_db_index](lib/shoulda/matchers/active_record/have_db_index_matcher.rb)**
  tests that the table that backs your model has an index on a specific column.
* **[have_many](lib/shoulda/matchers/active_record/association_matcher.rb)**
  tests your `has_many` associations.
* **[have_one](lib/shoulda/matchers/active_record/association_matcher.rb)**
  tests your `has_one` associations.
* **[have_readonly_attribute](lib/shoulda/matchers/active_record/have_readonly_attribute_matcher.rb)**
  tests usage of the `attr_readonly` macro.
* **[serialize](lib/shoulda/matchers/active_record/serialize_matcher.rb)** tests
  usage of the `serialize` macro.
* **[validate_uniqueness_of](lib/shoulda/matchers/active_record/validate_uniqueness_of_matcher.rb)**
  tests usage of `validates_uniqueness_of`.

### ActionController matchers

* **[filter_param](lib/shoulda/matchers/action_controller/filter_param_matcher.rb)**
  tests parameter filtering configuration.
* **[permit](lib/shoulda/matchers/action_controller/permit_matcher.rb)** tests
  that an action places a restriction on the `params` hash.
* **[redirect_to](lib/shoulda/matchers/action_controller/redirect_to_matcher.rb)**
  tests that an action redirects to a certain location.
* **[render_template](lib/shoulda/matchers/action_controller/render_template_matcher.rb)**
  tests that an action renders a template.
* **[render_with_layout](lib/shoulda/matchers/action_controller/render_with_layout_matcher.rb)**
  tests that an action is rendered with a certain layout.
* **[rescue_from](lib/shoulda/matchers/action_controller/rescue_from_matcher.rb)**
  tests usage of the `rescue_from` macro.
* **[respond_with](lib/shoulda/matchers/action_controller/respond_with_matcher.rb)**
  tests that an action responds with a certain status code.
* **[route](lib/shoulda/matchers/action_controller/route_matcher.rb)** tests
  your routes.
* **[set_session](lib/shoulda/matchers/action_controller/set_session_matcher.rb)**
  makes assertions on the `session` hash.
* **[set_flash](lib/shoulda/matchers/action_controller/set_flash_matcher.rb)**
  makes assertions on the `flash` hash.
* **[use_after_action](lib/shoulda/matchers/action_controller/callback_matcher.rb#L79)**
  tests that an `after_action` callback is defined in your controller.
* **[use_around_action](lib/shoulda/matchers/action_controller/callback_matcher.rb#L129)**
  tests that an `around_action` callback is defined in your controller.
* **[use_before_action](lib/shoulda/matchers/action_controller/callback_matcher.rb#L54)**
  tests that a `before_action` callback is defined in your controller.

### Independent matchers

* **[delegate_method](lib/shoulda/matchers/independent/delegate_method_matcher.rb)**
  tests that an object forwards messages to other, internal objects by way of
  delegation.

## Contributing

Shoulda Matchers is open source, and we are grateful for
[everyone][contributors] who's contributed so far.

If you'd like to contribute, please take a look at the
[instructions](CONTRIBUTING.md) for installing dependencies and crafting a good
pull request.

## Versioning

Shoulda Matchers follows Semantic Versioning 2.0 as defined at
<http://semver.org>.

## License

Shoulda Matchers is copyright © 2006-2018
[thoughtbot, inc][thoughtbot-website]. It is free software,
and may be redistributed under the terms specified in the
[MIT-LICENSE](MIT-LICENSE) file.

## About thoughtbot

![thoughtbot][thoughtbot-logo]

Shoulda Matchers is maintained and funded by thoughtbot, inc. The names and
logos for thoughtbot are trademarks of thoughtbot, inc.

We are passionate about open source software. See [our other
projects][community]. We are [available for hire][hire].

[rubydocs]: http://matchers.shoulda.io/docs/v4.0.0.rc1
[community]: https://thoughtbot.com/community?utm_source=github
[hire]: https://thoughtbot.com?utm_source=github
[version-badge]: https://img.shields.io/gem/v/shoulda-matchers.svg
[rubygems]: httpss://rubygems.org/gems/shoulda-matchers
[travis-badge]: https://img.shields.io/travis/thoughtbot/shoulda-matchers/master.svg
[travis]: https://travis-ci.org/thoughtbot/shoulda-matchers
[downloads-badge]: https://img.shields.io/gem/dtv/shoulda-matchers.svg
[contributors]: https://github.com/thoughtbot/shoulda-matchers/contributors
[shoulda]: https://github.com/thoughtbot/shoulda
[shoulda-context]: https://github.com/thoughtbot/shoulda-context
[Zeus]: https://github.com/burke/zeus
[Appraisal]: https://github.com/thoughtbot/appraisal
[hound-badge]: https://img.shields.io/badge/Reviewed_by-Hound-8E64B0.svg
[hound]: https://houndci.com
[thoughtbot-website]: https://thoughtbot.com
[thoughtbot-logo]: https://presskit.thoughtbot.com/images/thoughtbot-logo-for-readmes.svg
[logo]: https://matchers.shoulda.io/images/shoulda-matchers-logo.png
[website]: https://matchers.shoulda.io/
