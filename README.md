# shoulda-matchers [![Gem Version][version-badge]][rubygems] [![Build Status][travis-badge]][travis] ![Downloads][downloads-badge]

[Official Documentation][rubydocs]

shoulda-matchers provides Test::Unit- and RSpec-compatible one-liners that test
common Rails functionality. These tests would otherwise be much longer, more
complex, and error-prone.

### ActiveModel Matchers

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

### ActiveRecord Matchers

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

### ActionController Matchers

* **[filter_param](lib/shoulda/matchers/action_controller/filter_param_matcher.rb)**
  tests parameter filtering configuration.
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
* **[use_after_action](lib/shoulda/matchers/action_controller/use_after_action.rb)**
  tests that a `after_action` callback is defined in your controller. (Aliased
  as *use_after_filter*.)
* **[use_around_action](lib/shoulda/matchers/action_controller/use_around_action.rb)**
  tests that a `around_action` callback is defined in your controller. (Aliased
  as *use_around_filter*.)
* **[use_before_action](lib/shoulda/matchers/action_controller/use_before_action.rb)**
  tests that a `before_action` callback is defined in your controller. (Aliased
  as *use_before_filter*.)

### Independent Matchers

* **[delegate_method](lib/shoulda/matchers/independent/delegate_method_matcher.rb)**
  tests that an object forwards messages to other, internal objects by way of
  delegation.

## Installation

### RSpec

Include the gem in your Gemfile:

``` ruby
group :test do
  gem 'shoulda-matchers', require: false
end
```

Then require the gem following rspec-rails in your rails_helper (or spec_helper
if you're using RSpec 2.x):

``` ruby
require 'rspec/rails'
require 'shoulda/matchers'
```

### Test::Unit

shoulda-matchers was originally a component of [Shoulda][shoulda], a meta-gem
that also provides `should` and `context` syntax via
[shoulda-context][shoulda-context]. For this reason you'll want to include this
gem in your Gemfile instead:

```ruby
group :test do
  gem 'shoulda'
end
```

### Non-Rails apps

Once it is loaded, shoulda-matchers automatically includes itself into your test
framework. It will mix in the appropriate matchers for ActiveRecord,
ActiveModel, and ActionController depending on the modules that are available at
runtime. For instance, in order to use the ActiveRecord matchers, ActiveRecord
must be present beforehand.

If your application is written against Rails, everything should "just work", as
shoulda-matchers will most likely be declared after Rails in your Gemfile. If
your application is written against another framework such as Sinatra or
Padrino, you may have a different setup, so you will want to ensure that you are
requiring shoulda-matchers after the components of Rails you are using. For
instance, if you wanted to use and test against ActiveModel, you'd say:

```ruby
gem 'activemodel'
gem 'shoulda-matchers'
```

and not:

```ruby
gem 'shoulda-matchers'
gem 'activemodel'
```

## Generating documentation

YARD is used to generate documentation, which can be viewed [online][rubydocs].
You can preview changes you make to the documentation locally by running

    yard doc

from this directory. Then, open `doc/index.html` in your browser.

If you want to see a live preview as you work without having to run `yard` over
and over again, keep this command running in a separate terminal session:

    watchr docs.watchr

## Versioning

shoulda-matchers follows Semantic Versioning 2.0 as defined at
<http://semver.org>.

## Credits

shoulda-matchers is maintained and funded by [thoughtbot][community]. Thank you
to all the [contributors][contributors].

## License

shoulda-matchers is copyright © 2006-2014 thoughtbot, inc. It is free software,
and may be redistributed under the terms specified in the
[MIT-LICENSE](MIT-LICENSE) file.

[version-badge]: http://img.shields.io/gem/v/shoulda-matchers.svg
[rubygems]: http://rubygems.org/gems/shoulda-matchers
[travis-badge]: http://img.shields.io/travis/thoughtbot/shoulda-matchers/master.svg
[travis]: http://travis-ci.org/thoughtbot/shoulda-matchers
[downloads-badge]: http://img.shields.io/gem/dtv/shoulda-matchers.svg
[rubydocs]: http://matchers.shoulda.io/docs
[community]: http://thoughtbot.com/community
[contributors]: https://github.com/thoughtbot/shoulda-matchers/contributors
[shoulda]: http://github.com/thoughtbot/shoulda
[shoulda-context]: http://github.com/thoughtbot/shoulda-context
