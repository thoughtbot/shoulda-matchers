# Shoulda Matchers [![Gem Version][version-badge]][rubygems] [![Build Status][travis-badge]][travis] ![Downloads][downloads-badge]

[![Join the chat at https://gitter.im/shoulda-matchers/Lobby](https://badges.gitter.im/shoulda-matchers/Lobby.svg)](https://gitter.im/shoulda-matchers/Lobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Shoulda Matchers provides RSpec- and Minitest-compatible one-liners that test
common Rails functionality. These tests would otherwise be much longer, more
complex, and error-prone.

[View the official documentation for the latest version (3.1.1).][rubydocs]

----

### Note from the maintainer

> Are you a fan of Shoulda Matchers? Are you interested in maintaining a popular
> open-source project? If so, please contact me. Don't misunderstand me -- I
> still use Shoulda Matchers on every project, but unfortunately, it has been a
> long while since I've been able to give it the love it deserves, and I'd like
> to hand the reins over to someone else who is able to do that. If you're
> interested, I can be reached on Twitter as @mcmire or at
> <elliot.winkler@gmail.com>. Thanks!
>
> -- Elliot

----

### ActiveModel matchers

* **[allow_mass_assignment_of](lib/shoulda/matchers/active_model/allow_mass_assignment_of_matcher.rb)**
  tests usage of Rails 3's `attr_accessible` and `attr_protected` macros.
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
  tests that an `after_action` callback is defined in your controller. *(Aliased
  as #use_after_filter.)*
* **[use_around_action](lib/shoulda/matchers/action_controller/callback_matcher.rb#L129)**
  tests that an `around_action` callback is defined in your controller. *(Aliased
  as #use_around_filter.)*
* **[use_before_action](lib/shoulda/matchers/action_controller/callback_matcher.rb#L54)**
  tests that a `before_action` callback is defined in your controller. *(Aliased
  as #use_before_filter.)*

### Independent matchers

* **[delegate_method](lib/shoulda/matchers/independent/delegate_method_matcher.rb)**
  tests that an object forwards messages to other, internal objects by way of
  delegation.

## Getting started

### RSpec

Include `shoulda-matchers` in your Gemfile:

For Rails 4.x:

``` ruby
group :test do
  gem 'shoulda-matchers', '~> 3.1'
end
```

For Rails 5.0:

``` ruby
group :test do
  gem 'shoulda-matchers', git: 'https://github.com/thoughtbot/shoulda-matchers.git', branch: 'rails-5'
end
```

Now you need to tell the gem a couple of things:

* Which test framework you're using
* Which portion of the matchers you want to use

You can supply this information by using a configuration block. Place the
following in `rails_helper.rb`:

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

Now you can use matchers in your tests. For instance a model test might look
like this:

``` ruby
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

``` ruby
RSpec.configure do |config|
  config.include(Shoulda::Matchers::ActiveModel, type: :model)
  config.include(Shoulda::Matchers::ActiveRecord, type: :model)
end
```

Then you can say:

``` ruby
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

``` ruby
RSpec.describe Person, type: :model do
  it { is_expected.to validate_presence_of(:name) }
end
```

### Minitest

Shoulda Matchers was originally a component of [Shoulda][shoulda], a gem that
also provides `should` and `context` syntax via
[`shoulda-context`][shoulda-context].

At the moment, `shoulda` has not been updated to support `shoulda-matchers` 3.x,
so you'll want to add the following to your Gemfile:

```ruby
group :test do
  gem 'shoulda', '~> 3.5'
  gem 'shoulda-matchers', '~> 2.0'
end
```

Now you can use matchers in your tests. For instance a model test might look
like this:

``` ruby
class PersonTest < ActiveSupport::TestCase
  should validate_presence_of(:name)
end
```

## Running tests

### Unit tests

Unit tests are the most common kind of tests in this gem, and the best way to
run them is by using [Zeus].

You'll want to run `zeus start` in one shell, then in another shell, instead of
using `rspec` to run tests, you can use `zeus rspec`. So for instance, you might
say:

```
zeus rspec spec/unit/shoulda/matchers/active_model/validate_inclusion_of_matcher_spec.rb
```

As a shortcut, you can also drop the initial part of the path and say this
instead:

```
zeus rspec active_model/validate_inclusion_of_matcher_spec.rb
```

### Acceptance tests

The gem uses [Appraisal] to test against multiple versions of Rails and Ruby.
This means that if you're trying to run a single test file, you'll need to
specify which appraisal to use. For instance, you can't simply say:

```
rspec spec/acceptance/active_model_integration_spec.rb
```

Instead, you need to say

```
bundle exec appraisal 4.2 rspec spec/acceptance/active_model_integration_spec.rb
```

### All tests

You can run all tests by saying:

```
bundle exec rake
```

## Generating documentation

YARD is used to generate documentation, which can be viewed [online][rubydocs].
You can preview changes you make to the documentation locally by running

    yard doc

from this directory. Then, open `doc/index.html` in your browser.

If you want to be able to regenerate the docs as you work without having to run
`yard doc` over and over again, keep this command running in a separate terminal
session:

    rake docs:autogenerate

## Contributing

Shoulda Matchers is open source, and we are grateful for
[everyone][contributors] who's contributed so far.

If you'd like to contribute, please take a look at the
[instructions](CONTRIBUTING.md) for installing dependencies and crafting a good
pull request.

## Compatibility

Shoulda Matchers is tested and supported against Rails 4.x, RSpec 3.x, Minitest
5, Minitest 4, and Ruby 2.x.

## Versioning

Shoulda Matchers follows Semantic Versioning 2.0 as defined at
<http://semver.org>.

## License

Shoulda Matchers is copyright © 2006-2016
[thoughtbot, inc](https://thoughtbot.com/). It is free software,
and may be redistributed under the terms specified in the
[MIT-LICENSE](MIT-LICENSE) file.

## About thoughtbot

![thoughtbot](http://presskit.thoughtbot.com/images/thoughtbot-logo-for-readmes.svg)

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
[Zeus]: https://github.com/burke/zeus
[Appraisal]: https://github.com/thoughtbot/appraisal
