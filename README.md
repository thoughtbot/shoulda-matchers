# shoulda-matchers [![Gem Version](https://badge.fury.io/rb/shoulda-matchers.png)](http://badge.fury.io/rb/shoulda-matchers) [![Build Status](https://secure.travis-ci.org/thoughtbot/shoulda-matchers.png?branch=master)](http://travis-ci.org/thoughtbot/shoulda-matchers)

[Official Documentation](http://rubydoc.info/github/thoughtbot/shoulda-matchers/master/frames)

Test::Unit- and RSpec-compatible one-liners that test common Rails functionality.
These tests would otherwise be much longer, more complex, and error-prone.

Refer to the [shoulda-context](https://github.com/thoughtbot/shoulda-context) gem if you want to know more
about using shoulda with Test::Unit.

## ActiveRecord Matchers

Matchers to test associations:

```ruby
describe Post do
  it { should belong_to(:user) }
  it { should have_many(:tags).through(:taggings) }
end

describe User do
  it { should have_many(:posts) }
end
```

## ActiveModel Matchers

Matchers to test validations and mass assignments:

```ruby
describe Post do
  it { should validate_uniqueness_of(:title) }
  it { should validate_uniqueness_of(:title).scoped_to(:user_id, :category_id) }
  it { should validate_presence_of(:body).with_message(/wtf/) }
  it { should validate_presence_of(:title) }
  it { should validate_numericality_of(:user_id) }
  it { should ensure_inclusion_of(:status).in_array(['draft', 'public']) }
end

describe User do
  it { should_not allow_value("blah").for(:email) }
  it { should allow_value("a@b.com").for(:email) }
  it { should ensure_inclusion_of(:age).in_range(1..100) }
  it { should_not allow_mass_assignment_of(:password) }
end
```

## ActionController Matchers

Matchers to test common patterns:

```ruby
describe PostsController, "#show" do
  it { should permit(:title, :body).for(:create) }

  context "for a fictional user" do
    before do
      get :show, :id => 1
    end

    it { should respond_with(:success) }
    it { should render_template(:show) }
    it { should_not set_the_flash }
  end
end
```

## Installation

In Rails 3 and Bundler, add the following to your Gemfile:

```ruby
group :test do
  gem "shoulda-matchers"
end

# `rspec-rails` needs to be in the development group so that Rails generators work.
group :development, :test do
  gem "rspec-rails", "~> 2.12"
end
```

Shoulda will automatically include matchers into the appropriate example groups.

## Credits

Shoulda is maintained and funded by [thoughtbot](http://thoughtbot.com/community).
Thank you to all the [contributors](https://github.com/thoughtbot/shoulda-matchers/contributors).

## License

Shoulda is Copyright © 2006-2013 thoughtbot, inc.
It is free software, and may be redistributed under the terms specified in the MIT-LICENSE file.
