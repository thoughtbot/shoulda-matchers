# Shoulda Matchers [![Gem Version][version-badge]][rubygems] [![Build Status][travis-badge]][travis] [![Total Downloads][downloads-total]][rubygems] [![Downloads][downloads-badge]][rubygems] [![Hound][hound-badge]][hound]

[version-badge]: https://img.shields.io/gem/v/shoulda-matchers.svg
[rubygems]: https://rubygems.org/gems/shoulda-matchers
[travis-badge]: https://img.shields.io/travis/thoughtbot/shoulda-matchers/master.svg
[travis]: https://travis-ci.org/thoughtbot/shoulda-matchers
[downloads-total]: https://img.shields.io/gem/dt/shoulda-matchers.svg
[downloads-badge]: https://img.shields.io/gem/dtv/shoulda-matchers.svg
[downloads-badge]: https://img.shields.io/gem/dtv/shoulda-matchers.svg
[hound-badge]: https://img.shields.io/badge/Reviewed_by-Hound-8E64B0.svg
[hound]: https://houndci.com

[![shoulda-matchers][logo]][website]

[logo]: https://matchers.shoulda.io/images/shoulda-matchers-logo.png
[website]: https://matchers.shoulda.io/

Shoulda Matchers provides RSpec- and Minitest-compatible one-liners to test
common Rails functionality that, if written by hand, would be much longer, more
complex, and error-prone.

## Quick links

📖 **[Read the documentation for the latest version][rubydocs].**  
📢 **[See what's changed in a recent version][news].**

[rubydocs]: http://matchers.shoulda.io/docs
[news]: NEWS.md

## Table of contents

* [Getting started](#getting-started)
   * [RSpec](#rspec)
   * [Minitest](#minitest)
* [Usage](#usage)
  * [On the subject of `subject`](#on-the-subject-of-subject)
  * [Availability of RSpec matchers in example groups](#availability-of-rspec-matchers-in-example-groups)
  * [`should` vs `is_expected.to`](#should-vs-is_expectedto)
* [Matchers](#matchers)
   * [ActiveModel matchers](#activemodel-matchers)
   * [ActiveRecord matchers](#activerecord-matchers)
   * [ActionController matchers](#actioncontroller-matchers)
   * [Independent matchers](#independent-matchers)
* [Compatibility](#compatibility)
* [Contributing](#contributing)
* [Versioning](#versioning)
* [License](#license)
* [About thoughtbot](#about-thoughtbot)

## Getting started

### RSpec

Start by including `shoulda-matchers` in your Gemfile:

```ruby
group :test do
  gem 'shoulda-matchers'
end
```

Now you need to tell the gem a couple of things:

* Which test framework you're using
* Which portion of the matchers you want to use

You can supply this information by providing a configuration block. Where this
goes and what this contains depends on your project.

#### Rails apps

Assuming you are testing a Rails app, simply place this at the bottom of
`spec/rails_helper.rb` (or in a support file if you so choose):

```ruby
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
```

Now you're ready to [use matchers in your tests](#usage)!

#### Non-Rails apps

If your project isn't a Rails app, but you still make use of ActiveRecord or
ActiveModel, you can still use this gem too! In that case, you'll want to place
the following configuration at the bottom of `spec/spec_helper.rb`:

```ruby
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec

    # Keep as many of these lines as are necessary:
    with.library :active_record
    with.library :active_model
  end
end
```

Now you're ready to [use matchers in your tests](#usage)!

### Minitest

Shoulda Matchers was originally a component of [Shoulda][shoulda], a gem that
also provides `should` and `context` syntax via
[`shoulda-context`][shoulda-context].

[shoulda]: https://github.com/thoughtbot/shoulda
[shoulda-context]: https://github.com/thoughtbot/shoulda-context

At the moment, `shoulda` has not been updated to support `shoulda-matchers` 3.x
and 4.x, so you'll want to add the following to your Gemfile:

```ruby
group :test do
  gem 'shoulda', '~> 3.5'
  gem 'shoulda-matchers', '~> 2.0'
  gem 'rails-controller-testing'
end
```

Now you're ready to [use matchers in your tests](#usage)!

## Usage

The matchers provided by this gem are divided into different categories
depending on what you're testing within your Rails app:

* [database models backed by ActiveRecord](#activemodel-matchers)
* [non-database models, form objects, etc. backed by
  ActiveModel](#activerecord-matchers)
* [controllers](#actioncontroller-matchers)
* [routes](#routing-matchers) (RSpec only)
* [usage of Rails-specific features like `delegate`](#independent-matchers)

All matchers are designed to be prepended primarily with the word `should`,
which is a special directive in both RSpec and Shoulda. For instance, a model
test case may look something like:

``` ruby
# RSpec
RSpec.describe MenuItem, type: :model do
  describe 'associations' do
    it { should belong_to(:category).class_name('MenuCategory') }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name).scoped_to(:category_id) }
  end
end

# Minitest (Shoulda)
class MenuItemTest < ActiveSupport::TestCase
  context 'associations' do
    should belong_to(:category).class_name('MenuCategory')
  end

  context 'validations' do
    should validate_presence_of(:name)
    should validate_uniqueness_of(:name).scoped_to(:category_id)
  end
end
```

For the full set of matchers you can use, [see below](#matchers).

### On the subject of `subject`

For both RSpec and Shoulda, the **subject** is an implicit reference to the
object under test, and all of the matchers make use of it internally when they
are run. This is always set automatically by your test framework in any given
test case; however, in certain cases it can be advantageous to override the
subject. For instance, when testing validations in a model, it is customary to
provide a valid model instead of a fresh one:

``` ruby
# RSpec
RSpec.describe Post, type: :model do
  describe 'validations' do
    # Here we're using FactoryBot, but you could use anything
    subject { build(:post) }

    it { should validate_presence_of(:title) }
  end
end

# Minitest (Shoulda)
class PostTest < ActiveSupport::TestCase
  context 'validations' do
    subject { build(:post) }

    should validate_presence_of(:title)
  end
end
```

When overriding the subject in this manner, then, it's important to provide the
correct object. **When in doubt, provide an instance of the class under test.**
This is particularly necessary for controller tests, where it is easy to
accidentally write something like:

``` ruby
RSpec.describe PostsController, type: :controller do
  describe 'GET #index' do
    subject { get :index }

    # This may work...
    it { should have_http_status(:success) }
    # ...but this will not!
    it { should permit(:title, :body).for(:post) }
  end
end
```

In this case, you would want to use `before` rather than `subject`:

``` ruby
RSpec.describe PostsController, type: :controller do
  describe 'GET #index' do
    before { get :index }

    # Notice that we have to assert have_http_status on the response here...
    it { expect(response).to have_http_status(:success) }
    # ...but we do not have to provide a subject for render_template
    it { should render_template('index') }
  end
end
```

### Availability of RSpec matchers in example groups

If you're using RSpec, then you're probably familiar with the concept of example
groups: these are different kinds of test cases, and each of them has special
behavior around them. As alluded to [above](#usage), this gem works in a similar
way, and there are matchers that are only available in certain types of example
groups:

* ActiveRecord and ActiveModel matchers are available only in model example
  groups, i.e., those tagged with `type: :model` or in files located under
  `spec/models`.
* ActionController matchers are available only in controller example groups,
  i.e., those tagged with `type: :controller` or in files located under
  `spec/controllers`.
* The `route` matcher is available in routing example groups, i.e., those
  tagged with `type: :routing` or in files located under `spec/routing`.
* Independent matchers are available in all example groups.

As long as you're using Rails, you don't need to worry about this — everything
should "just work".

**However, if you are using ActiveModel or ActiveRecord outside of Rails**, and
you want to use model matchers in certain example groups, you'll need to
manually include the module that holds those matchers. A good way to do this is
to place the following in your `spec_helper.rb`:

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

### `should` vs `is_expected.to`

In this README and throughout the documentation, we're using the `should` form
of RSpec's one-liner syntax over `is_expected.to`. The `should` form works
regardless of how you've configured RSpec — meaning you can still use it even
when using the `expect` syntax. But if you prefer to use `is_expected.to`, you
can do that too:

```ruby
RSpec.describe Person, type: :model do
  it { is_expected.to validate_presence_of(:name) }
end
```

## Matchers

The following is a list of matchers shipped with the gem. If you need details
about any of them, make sure to [consult the documentation][rubydocs]!

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
* **[have_rich_text](lib/shoulda/matchers/active_record/have_rich_text_matcher.rb)**
  tests your `has_rich_text` associations.
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

### Routing matchers

* **[route](lib/shoulda/matchers/action_controller/route_matcher.rb)** tests
  your routes.

### Independent matchers

* **[delegate_method](lib/shoulda/matchers/independent/delegate_method_matcher.rb)**
  tests that an object forwards messages to other, internal objects by way of
  delegation.

## Compatibility

Shoulda Matchers is tested and supported against Ruby 2.4+, Rails 5.x, Rails
4.2.x, RSpec 3.x, and Minitest 5.x.

For Ruby < 2.4 and Rails < 4.1 compatibility, please use [v3.1.3][v3.1.3].

[v3.1.3]: https://github.com/thoughtbot/shoulda-matchers/releases/tag/v3.1.3

## Contributing

Shoulda Matchers is open source, and we are grateful for
[everyone][contributors] who's contributed so far.

[contributors]: https://github.com/thoughtbot/shoulda-matchers/contributors

If you'd like to contribute, please take a look at the
[instructions](CONTRIBUTING.md) for installing dependencies and crafting a good
pull request.

## Versioning

Shoulda Matchers follows Semantic Versioning 2.0 as defined at
<http://semver.org>.

## License

Shoulda Matchers is copyright © 2006-2020
[thoughtbot, inc][thoughtbot-website]. It is free software,
and may be redistributed under the terms specified in the
[MIT-LICENSE](MIT-LICENSE) file.

[thoughtbot-website]: https://thoughtbot.com

## About thoughtbot

![thoughtbot][thoughtbot-logo]

[thoughtbot-logo]: https://presskit.thoughtbot.com/images/thoughtbot-logo-for-readmes.svg

Shoulda Matchers is maintained and funded by thoughtbot, inc. The names and
logos for thoughtbot are trademarks of thoughtbot, inc.

We are passionate about open source software. See [our other
projects][community]. We are [available for hire][hire].

[community]: https://thoughtbot.com/community?utm_source=github
[hire]: https://thoughtbot.com?utm_source=github
