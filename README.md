# Shoulda Matchers [![Gem Version][version-badge]][rubygems] [![Build Status][travis-badge]][travis] ![Downloads][downloads-badge]

Shoulda Matchers provides RSpec- and Minitest-compatible one-liners that test
common Rails functionality. These tests would otherwise be much longer, more
complex, and error-prone.

[View the official documentation for the latest version (2.8.0).][rubydocs]

**Heads up! This is the README for the master branch. [You might be more
interested in the README for 2.8.0 instead.][2.8.0-README]**

----

### ActiveModel matchers

* **[allow_mass_assignment_of](lib/shoulda/matchers/active_model/allow_mass_assignment_of_matcher.rb)**
  tests usage of Rails 3's `attr_accessible` and `attr_protected` macros.
* **[allow_value](lib/shoulda/matchers/active_model/allow_value_matcher.rb)**
  tests usage of the `validates_format_of` validation.
* **[have_secure_password](lib/shoulda/matchers/active_model/have_secure_password_matcher.rb)**
  tests usage of `has_secure_password`.
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
  tests that a `after_action` callback is defined in your controller. (Aliased
  as *use_after_filter*.)
* **[use_around_action](lib/shoulda/matchers/action_controller/callback_matcher.rb#L129)**
  tests that a `around_action` callback is defined in your controller. (Aliased
  as *use_around_filter*.)
* **[use_before_action](lib/shoulda/matchers/action_controller/callback_matcher.rb#L54)**
  tests that a `before_action` callback is defined in your controller. (Aliased
  as *use_before_filter*.)

### Independent matchers

* **[delegate_method](lib/shoulda/matchers/independent/delegate_method_matcher.rb)**
  tests that an object forwards messages to other, internal objects by way of
  delegation.

## Installation

### RSpec

Include `shoulda-matchers` in your Gemfile:

``` ruby
group :test do
  gem 'shoulda-matchers'
end
```

[Then, configure the gem to integrate with RSpec](#configuration).

Now you can use matchers in your tests. For instance a model test might look
like this, depending on your RSpec syntax:

``` ruby
# config.syntax = :expect
describe Person do
  it { is_expected.to validate_presence_of(:name) }
end

# config.syntax = :should
describe Person do
  it { should validate_presence_of(:name) }
end
```

### Minitest / Test::Unit

Shoulda Matchers was originally a component of [Shoulda][shoulda], a gem that
also provides `should` and `context` syntax via
[`shoulda-context`][shoulda-context]. For this reason you'll want to include this
gem in your Gemfile instead:

```ruby
group :test do
  gem 'shoulda'
end
```

[Then, configure the gem to integrate with Minitest](#configuration).

Now you can use matchers in your tests. For instance a model test might look
like this:

``` ruby
class PersonTest < ActiveSupport::TestCase
  should validate_presence_of(:name)
end
```

### Configuration

**NOTE: The new configuration syntax isn't available in a public release just
yet -- please refer to the [README for 2.8.0][2.8.0-README] for the current
installation instructions.**

Before you can use Shoulda Matchers, you'll need to tell it a couple of things:

* Which test framework you're using
* Which portion of the matchers you want to use

You can supply this information by using a configuration block. Place the
following in your test or spec helper:

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

## Generating documentation

YARD is used to generate documentation, which can be viewed [online][rubydocs].
You can preview changes you make to the documentation locally by running

    yard doc

from this directory. Then, open `doc/index.html` in your browser.

If you want to see a live preview as you work without having to run `yard` over
and over again, keep this command running in a separate terminal session:

    bundle exec guard

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

Shoulda Matchers is copyright © 2006-2015
[thoughtbot, inc](https://thoughtbot.com/). It is free software,
and may be redistributed under the terms specified in the
[MIT-LICENSE](MIT-LICENSE) file.

## About thoughtbot

![thoughtbot](https://thoughtbot.com/logo.png)

Shoulda Matchers is maintained and funded by thoughtbot, inc.
The names and logos for thoughtbot are trademarks of thoughtbot, inc.

We are passionate about open source software.
See [our other projects][community].
We are [available for hire][hire].

[community]: https://thoughtbot.com/community?utm_source=github
[hire]: https://thoughtbot.com?utm_source=github
[version-badge]: http://img.shields.io/gem/v/shoulda-matchers.svg
[rubygems]: http://rubygems.org/gems/shoulda-matchers
[travis-badge]: http://img.shields.io/travis/thoughtbot/shoulda-matchers/master.svg
[travis]: http://travis-ci.org/thoughtbot/shoulda-matchers
[downloads-badge]: http://img.shields.io/gem/dtv/shoulda-matchers.svg
[rubydocs]: http://matchers.shoulda.io/docs
[contributors]: https://github.com/thoughtbot/shoulda-matchers/contributors
[shoulda]: http://github.com/thoughtbot/shoulda
[shoulda-context]: http://github.com/thoughtbot/shoulda-context
[2.8.0-README]: https://github.com/thoughtbot/shoulda-matchers/tree/v2.8.0#shoulda-matchers---
