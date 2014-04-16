# shoulda-matchers [![Gem Version][fury-badge]][fury] [![Build Status][travis-badge]][travis]

[Official Documentation][rubydocs]

shoulda-matchers provides Test::Unit- and RSpec-compatible one-liners that test
common Rails functionality. These tests would otherwise be much longer, more
complex, and error-prone.

## Installation

### RSpec

Include the gem in your Gemfile:

```ruby
group :test do
  gem 'shoulda-matchers'
end
```

Note that if you're using a Rails preloader like Spring, you'll need to manually
require shoulda-matchers in your spec_helper after you require RSpec:

```ruby
# Gemfile
group :test do
  gem 'shoulda-matchers', require: false
end

# spec_helper
require 'rspec/rails'
require 'shoulda/matchers'
```

### Test::Unit

shoulda-matchers was originally a component of
[Shoulda](http://github.com/thoughtbot/shoulda) -- it's what provides the nice
`should` syntax which is demonstrated below. For this reason, include it in
your Gemfile instead:

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
must be available beforehand.

If your application is on Rails, everything should "just work", as
shoulda-matchers will most likely be declared after Rails in your Gemfile. If
your application is on another framework such as Sinatra or Padrino, you may
have a different setup, so you will want to ensure that you are requiring
shoulda-matchers after the components of Rails you are using. For instance,
if you wanted to use and test against ActiveModel, you'd say:

```ruby
gem 'activemodel'
gem 'shoulda-matchers'
```

and not:

```ruby
gem 'shoulda-matchers'
gem 'activemodel'
```

## Usage

Different matchers apply to different parts of Rails:

* [ActiveModel](#activemodel-matchers)
* [ActiveRecord](#activerecord-matchers)
* [ActionController](#actioncontroller-matchers)

### ActiveModel Matchers

*Jump to: [allow_mass_assignment_of](#allow_mass_assignment_of), [allow_value](#allow_value), [ensure_inclusion_of](#ensure_inclusion_of), [ensure_exclusion_of](#ensure_exclusion_of), [ensure_length_of](#ensure_length_of), [have_secure_password](#have_secure_password), [validate_absence_of](#validate_absence_of), [validate_acceptance_of](#validate_acceptance_of), [validate_confirmation_of](#validate_confirmation_of), [validate_numericality_of](#validate_numericality_of), [validate_presence_of](#validate_presence_of), [validate_uniqueness_of](#validate_uniqueness_of)*

Note that all of the examples in this section are based on an ActiveRecord
model for simplicity, but these matchers will work just as well using an
ActiveModel model.

#### allow_mass_assignment_of

The `allow_mass_assignment_of` matcher tests usage of Rails 3's
`attr_accessible` and `attr_protected` macros, asserting that attributes can or
cannot be mass-assigned on a record.

```ruby
class Post < ActiveRecord::Base
  attr_accessible :title
  attr_accessible :published_status, as: :admin
end

class User < ActiveRecord::Base
  attr_protected :encrypted_password
end

# RSpec
describe Post do
  it { should allow_mass_assignment_of(:title) }
  it { should allow_mass_assignment_of(:published_status).as(:admin) }
end

describe User do
  it { should_not allow_mass_assignment_of(:encrypted_password) }
end

# Test::Unit
class PostTest < ActiveSupport::TestCase
  should allow_mass_assignment_of(:title)
  should allow_mass_assignment_of(:published_status).as(:admin)
end

class UserTest < ActiveSupport::TestCase
  should_not allow_mass_assignment_of(:encrypted_password)
end
```

#### allow_value

The `allow_value` matcher tests usage of the `validates_format_of` validation.
It asserts that an attribute can be set to one or more values, succeeding if
none of the values cause the record to be invalid.

```ruby
class UserProfile < ActiveRecord::Base
  validates_format_of :website_url, with: URI.regexp

  validates_format_of :birthday_as_string,
    with: /^(\d+)-(\d+)-(\d+)$/,
    on: :create

  validates_format_of :state,
    with: /^(open|closed)$/,
    message: 'State must be open or closed'
end

# RSpec
describe UserProfile do
  it { should allow_value('http://foo.com', 'http://bar.com/baz').for(:website_url) }
  it { should_not allow_value('asdfjkl').for(:website_url) }

  it do
    should allow_value('2013-01-01').
      for(:birthday_as_string).
      on(:create)
  end

  it do
    should allow_value('open', 'closed').
      for(:state).
      with_message('State must be open or closed')
  end
end

# Test::Unit
class UserProfileTest < ActiveSupport::TestCase
  should allow_value('http://foo.com', 'http://bar.com/baz').for(:website_url)
  should_not allow_value('asdfjkl').for(:website_url)

  should allow_value('2013-01-01').
    for(:birthday_as_string).
    on(:create)

  should allow_value('open', 'closed').
    for(:state).
    with_message('State must be open or closed')
end
```

**PLEASE NOTE:** Using `should_not` with `allow_value` completely negates the
assertion. This means that if multiple values are given to `allow_value`, the
matcher succeeds once it sees the *first* value that will cause the record to be
invalid:

```ruby
describe User do
  # 'b' and 'c' will not be tested
  it { should_not allow_value('a', 'b', 'c').for(:website_url) }
end
```

#### ensure_inclusion_of

The `ensure_inclusion_of` matcher tests usage of the `validates_inclusion_of`
validation, asserting that an attribute can take a set of values and cannot
take values outside of this set.

```ruby
class Issue < ActiveRecord::Base
  validates_inclusion_of :state, in: %w(open resolved unresolved)
  validates_inclusion_of :priority, in: 1..5

  validates_inclusion_of :severity,
    in: %w(low medium high),
    message: 'Severity must be low, medium, or high'
end

# RSpec
describe Issue do
  it { should ensure_inclusion_of(:state).in_array(%w(open resolved unresolved)) }
  it { should ensure_inclusion_of(:priority).in_range(1..5) }

  it do
    should ensure_inclusion_of(:severity).
      in_array(%w(low medium high)).
      with_message('Severity must be low, medium, or high')
  end
end

# Test::Unit
class IssueTest < ActiveSupport::TestCase
  should ensure_inclusion_of(:state).in_array(%w(open resolved unresolved))
  should ensure_inclusion_of(:priority).in_range(1..5)

  should ensure_inclusion_of(:severity).
    in_array(%w(low medium high)).
    with_message('Severity must be low, medium, or high')
end
```

#### ensure_exclusion_of

The `ensure_exclusion_of` matcher tests usage of the `validates_exclusion_of`
validation, asserting that an attribute cannot take a set of values.

```ruby
class Game < ActiveRecord::Base
  validates_exclusion_of :supported_os, in: ['Mac', 'Linux']
  validates_exclusion_of :floors_with_enemies, in: 5..8

  validates_exclusion_of :weapon,
    in: ['pistol', 'paintball gun', 'stick'],
    message: 'You chose a puny weapon'
end

# RSpec
describe Game do
  it { should ensure_exclusion_of(:supported_os).in_array(['Mac', 'Linux']) }
  it { should ensure_exclusion_of(:floors_with_enemies).in_range(5..8) }

  it do
    should ensure_exclusion_of(:weapon).
      in_array(['pistol', 'paintball gun', 'stick']).
      with_message('You chose a puny weapon')
  end
end

# Test::Unit
class GameTest < ActiveSupport::TestCase
  should ensure_exclusion_of(:supported_os).in_array(['Mac', 'Linux'])
  should ensure_exclusion_of(:floors_with_enemies).in_range(5..8)

  should ensure_exclusion_of(:weapon).
    in_array(['pistol', 'paintball gun', 'stick']).
    with_message('You chose a puny weapon')
end
```

#### ensure_length_of

The `ensure_length_of` matcher tests usage of the `validates_length_of` matcher.

```ruby
class User < ActiveRecord::Base
  validates_length_of :bio, minimum: 15
  validates_length_of :favorite_superhero, is: 6
  validates_length_of :status_update, maximum: 140
  validates_length_of :password, in: 5..30

  validates_length_of :api_token,
    in: 10..20,
    message: 'API token must be in between 10 and 20 characters'

  validates_length_of :secret_key, in: 15..100,
    too_short: 'Secret key must be more than 15 characters',
    too_long: 'Secret key cannot be more than 100 characters'
end

# RSpec
describe User do
  it { should ensure_length_of(:bio).is_at_least(15) }
  it { should ensure_length_of(:favorite_superhero).is_equal_to(6) }
  it { should ensure_length_of(:status_update).is_at_most(140) }
  it { should ensure_length_of(:password).is_at_least(5).is_at_most(30) }

  it do
    should ensure_length_of(:api_token).
      is_at_least(10).
      is_at_most(20).
      with_message('Password must be in between 10 and 20 characters')
  end

  it do
    should ensure_length_of(:secret_key).
      is_at_least(15).
      is_at_most(100).
      with_short_message('Secret key must be more than 15 characters').
      with_long_message('Secret key cannot be more than 100 characters')
  end
end

# Test::Unit
class UserTest < ActiveSupport::TestCase
  should ensure_length_of(:bio).is_at_least(15)
  should ensure_length_of(:favorite_superhero).is_equal_to(6)
  should ensure_length_of(:status_update).is_at_most(140)
  should ensure_length_of(:password).is_at_least(5).is_at_most(30)

  should ensure_length_of(:api_token).
    is_at_least(15).
    is_at_most(20).
    with_message('Password must be in between 15 and 20 characters')

  should ensure_length_of(:secret_key).
    is_at_least(15).
    is_at_most(100).
    with_short_message('Secret key must be more than 15 characters').
    with_long_message('Secret key cannot be more than 100 characters')
end
```

#### have_secure_password

The `have_secure_password` matcher tests usage of the `has_secure_password`
macro.

```ruby
class User < ActiveRecord::Base
  has_secure_password
end

# RSpec
describe User do
  it { should have_secure_password }
end

# Test::Unit
class UserTest < ActiveSupport::TestCase
  should have_secure_password
end
```

#### validate_absence_of

The `validate_absence_of` matcher tests the usage of the
`validates_absence_of` validation.

```ruby
class Tank
  include ActiveModel::Model

  validates_absence_of :arms
  validates_absence_of :legs,
    message: "Tanks don't have legs."
end

# RSpec
describe Tank do
  it { should validate_absence_of(:arms) }

  it do
    should validate_absence_of(:legs).
      with_message("Tanks don't have legs.")
  end
end

# Test::Unit
class TankTest < ActiveSupport::TestCase
  should validate_absence_of(:arms)

  should validate_absence_of(:legs).
    with_message("Tanks don't have legs.")
end
```

#### validate_acceptance_of

The `validate_acceptance_of` matcher tests usage of the
`validates_acceptance_of` validation.

```ruby
class Registration < ActiveRecord::Base
  validates_acceptance_of :eula
  validates_acceptance_of :terms_of_service,
    message: 'You must accept the terms of service'
end

# RSpec
describe Registration do
  it { should validate_acceptance_of(:eula) }

  it do
    should validate_acceptance_of(:terms_of_service).
      with_message('You must accept the terms of service')
  end
end

# Test::Unit
class RegistrationTest < ActiveSupport::TestCase
  should validate_acceptance_of(:eula)

  should validate_acceptance_of(:terms_of_service).
    with_message('You must accept the terms of service')
end
```

#### validate_confirmation_of

The `validate_confirmation_of` matcher tests usage of the
`validates_confirmation_of` validation.

```ruby
class User < ActiveRecord::Base
  validates_confirmation_of :email
  validates_confirmation_of :password, message: 'Please re-enter your password'
end

# RSpec
describe User do
  it do
    should validate_confirmation_of(:email)
  end

  it do
    should validate_confirmation_of(:password).
      with_message('Please re-enter your password')
  end
end

# Test::Unit
class UserTest < ActiveSupport::TestCase
  should validate_confirmation_of(:email)

  should validate_confirmation_of(:password).
    with_message('Please re-enter your password')
end
```

#### validate_numericality_of

The `validate_numericality_of` matcher tests usage of the
`validates_numericality_of` validation.

```ruby
class Person < ActiveRecord::Base
  validates_numericality_of :gpa
  validates_numericality_of :age, only_integer: true
  validates_numericality_of :legal_age, greater_than: 21
  validates_numericality_of :height, greater_than_or_equal_to: 55
  validates_numericality_of :weight, equal_to: 150
  validates_numericality_of :number_of_cars, less_than: 2
  validates_numericality_of :birth_year, less_than_or_equal_to: 1987
  validates_numericality_of :birth_day, odd: true
  validates_numericality_of :birth_month, even: true
  validates_numericality_of :rank, less_than_or_equal_to: 10, allow_nil: true

  validates_numericality_of :number_of_dependents,
    message: 'Number of dependents must be a number'
end

# RSpec
describe Person do
  it { should validate_numericality_of(:gpa) }
  it { should validate_numericality_of(:age).only_integer }
  it { should validate_numericality_of(:legal_age).is_greater_than(21) }
  it { should validate_numericality_of(:height).is_greater_than_or_equal_to(55) }
  it { should validate_numericality_of(:weight).is_equal_to(150) }
  it { should validate_numericality_of(:number_of_cars).is_less_than(2) }
  it { should validate_numericality_of(:birth_year).is_less_than_or_equal_to(1987) }
  it { should validate_numericality_of(:birth_day).odd }
  it { should validate_numericality_of(:birth_month).even }

  it do
    should validate_numericality_of(:number_of_dependents).
      with_message('Number of dependents must be a number')
  end
end

# Test::Unit
class PersonTest < ActiveSupport::TestCase
  should validate_numericality_of(:gpa)
  should validate_numericality_of(:age).only_integer
  should validate_numericality_of(:legal_age).is_greater_than(21)
  should validate_numericality_of(:height).is_greater_than_or_equal_to(55)
  should validate_numericality_of(:weight).is_equal_to(150)
  should validate_numericality_of(:number_of_cars).is_less_than(2)
  should validate_numericality_of(:birth_year).is_less_than_or_equal_to(1987)
  should validate_numericality_of(:birth_day).odd
  should validate_numericality_of(:birth_month).even

  should validate_numericality_of(:number_of_dependents).
    with_message('Number of dependents must be a number')
end
```

#### validate_presence_of

The `validate_presence_of` matcher tests usage of the `validates_presence_of`
matcher.

```ruby
class Robot < ActiveRecord::Base
  validates_presence_of :arms
  validates_presence_of :legs, message: 'Robot has no legs'
end

# RSpec
describe Robot do
  it { should validate_presence_of(:arms) }
  it { should validate_presence_of(:legs).with_message('Robot has no legs') }
end

# Test::Unit
class RobotTest < ActiveSupport::TestCase
  should validate_presence_of(:arms)
  should validate_presence_of(:legs).with_message('Robot has no legs')
end
```

#### validate_uniqueness_of

The `validate_uniqueness_of` matcher tests usage of the
`validates_uniqueness_of` validation.

```ruby
class Post < ActiveRecord::Base
  validates_uniqueness_of :permalink
  validates_uniqueness_of :slug, scope: :user_id
  validates_uniqueness_of :key, case_insensitive: true
  validates_uniqueness_of :author_id, allow_nil: true

  validates_uniqueness_of :title, message: 'Please choose another title'
end

# RSpec
describe Post do
  it { should validate_uniqueness_of(:permalink) }
  it { should validate_uniqueness_of(:slug).scoped_to(:user_id) }
  it { should validate_uniqueness_of(:key).case_insensitive }
  it { should validate_uniqueness_of(:author_id).allow_nil }

  it do
    should validate_uniqueness_of(:title).
      with_message('Please choose another title')
  end
end

# Test::Unit
class PostTest < ActiveSupport::TestCase
  should validate_uniqueness_of(:permalink)
  should validate_uniqueness_of(:slug).scoped_to(:user_id)
  should validate_uniqueness_of(:key).case_insensitive
  should validate_uniqueness_of(:author_id).allow_nil

  should validate_uniqueness_of(:title).
    with_message('Please choose another title')
end
```

**PLEASE NOTE:** This matcher works differently from other validation matchers.
Since the very concept of uniqueness depends on checking against a pre-existing
record in the database, this matcher will first use the model you're testing to
query for such a record, and if it can't find an existing one, it will create
one itself. Sometimes this step fails, especially if you have other validations
on the attribute you're testing (or, if you have database-level restrictions on
any attributes). In this case, the solution is to create a record before you use
`validate_uniqueness_of`.

For example, if you have this model:

```ruby
class Post < ActiveRecord::Base
  validates_presence_of :permalink
  validates_uniqueness_of :permalink
end
```

then you will need to test it like this:

```ruby
describe Post do
  it do
    Post.create!(title: 'This is the title')
    should validate_uniqueness_of(:permalink)
  end
end
```

### ActiveRecord Matchers

*Jump to: [accept_nested_attributes_for](#accept_nested_attributes_for), [belong_to](#belong_to), [have_many](#have_many), [have_one](#have_one), [have_and_belong_to_many](#have_and_belong_to_many), [have_db_column](#have_db_column), [have_db_index](#have_db_index), [have_readonly_attribute](#have_readonly_attribute), [serialize](#serialize)*

#### accept_nested_attributes_for

The `accept_nested_attributes_for` matcher tests usage of the
`accepts_nested_attributes_for` macro.

```ruby
class Car < ActiveRecord::Base
  accept_nested_attributes_for :doors
  accept_nested_attributes_for :mirrors, allow_destroy: true
  accept_nested_attributes_for :windows, limit: 3
  accept_nested_attributes_for :engine, update_only: true
end

# RSpec
describe Car do
  it { should accept_nested_attributes_for(:doors) }
  it { should accept_nested_attributes_for(:mirrors).allow_destroy(true) }
  it { should accept_nested_attributes_for(:windows).limit(3) }
  it { should accept_nested_attributes_for(:engine).update_only(true) }
end

# Test::Unit (using Shoulda)
class CarTest < ActiveSupport::TestCase
  should accept_nested_attributes_for(:doors)
  should accept_nested_attributes_for(:mirrors).allow_destroy(true)
  should accept_nested_attributes_for(:windows).limit(3)
  should accept_nested_attributes_for(:engine).update_only(true)
end
```

#### belong_to

The `belong_to` matcher tests your `belongs_to` associations.

```ruby
class Person < ActiveRecord::Base
  belongs_to :organization
  belongs_to :family, -> { where(everyone_is_perfect: false) }
  belongs_to :previous_company, -> { order('hired_on desc') }
  belongs_to :ancient_city, class_name: 'City'
  belongs_to :great_country, foreign_key: 'country_id'
  belongs_to :mental_institution, touch: true
  belongs_to :world, dependent: :destroy
end

# RSpec
describe Person do
  it { should belong_to(:organization) }
  it { should belong_to(:family).conditions(everyone_is_perfect: false) }
  it { should belong_to(:previous_company).order('hired_on desc') }
  it { should belong_to(:ancient_city).class_name('City') }
  it { should belong_to(:great_country).with_foreign_key('country_id') }
  it { should belong_to(:mental_institution).touch(true) }
  it { should belong_to(:world).dependent(:destroy) }
end

# Test::Unit
class PersonTest < ActiveSupport::TestCase
  should belong_to(:organization)
  should belong_to(:family).conditions(everyone_is_perfect: false)
  should belong_to(:previous_company).order('hired_on desc')
  should belong_to(:ancient_city).class_name('City')
  should belong_to(:great_country).with_foreign_key('country_id')
  should belong_to(:mental_institution).touch(true)
  should belong_to(:world).dependent(:destroy)
end
```

#### have_many

The `have_many` matcher tests your `has_many` and `has_many :through` associations.

```ruby
class Person < ActiveRecord::Base
  has_many :friends
  has_many :acquaintances, through: :friends
  has_many :job_offers, through: :friends, source: :opportunities
  has_many :coins, -> { where(condition: 'mint') }
  has_many :shirts, -> { order('color') }
  has_many :hopes, class_name: 'Dream'
  has_many :worries, foreign_key: 'worrier_id'
  has_many :distractions, counter_cache: true
  has_many :ideas, validate: false
  has_many :topics_of_interest, touch: true
  has_many :secret_documents, dependent: :destroy
end

# RSpec
describe Person do
  it { should have_many(:friends) }
  it { should have_many(:acquaintances).through(:friends) }
  it { should have_many(:job_offers).through(:friends).source(:opportunities) }
  it { should have_many(:coins).conditions(condition: 'mint') }
  it { should have_many(:shirts).order('color') }
  it { should have_many(:hopes).class_name('Dream') }
  it { should have_many(:worries).with_foreign_key('worrier_id') }
  it { should have_many(:ideas).validate(false) }
  it { should have_many(:distractions).counter_cache(true) }
  it { should have_many(:topics_of_interest).touch(true) }
  it { should have_many(:secret_documents).dependent(:destroy) }
end

# Test::Unit
class PersonTest < ActiveSupport::TestCase
  should have_many(:friends)
  should have_many(:acquaintances).through(:friends)
  should have_many(:job_offers).through(:friends).source(:opportunities)
  should have_many(:coins).conditions(condition: 'mint')
  should have_many(:shirts).order('color')
  should have_many(:hopes).class_name('Dream')
  should have_many(:worries).with_foreign_key('worrier_id')
  should have_many(:ideas).validate(false)
  should have_many(:distractions).counter_cache(true)
  should have_many(:topics_of_interest).touch(true)
  should have_many(:secret_documents).dependent(:destroy)
end
```

#### have_one

The `have_one` matcher tests your `has_one` and `has_one :through` associations.

```ruby
class Person < ActiveRecord::Base
  has_one :partner
  has_one :life, through: :partner
  has_one :car, through: :partner, source: :vehicle
  has_one :pet, -> { where('weight < 80') }
  has_one :focus, -> { order('priority desc') }
  has_one :chance, class_name: 'Opportunity'
  has_one :job, foreign_key: 'worker_id'
  has_one :parking_card, validate: false
  has_one :contract, dependent: :nullify
end

# RSpec
describe Person do
  it { should have_one(:partner) }
  it { should have_one(:life).through(:partner) }
  it { should have_one(:car).through(:partner).source(:vehicle) }
  it { should have_one(:pet).conditions('weight < 80') }
  it { should have_one(:focus).order('priority desc') }
  it { should have_one(:chance).class_name('Opportunity') }
  it { should have_one(:job).with_foreign_key('worker_id') }
  it { should have_one(:parking_card).validate(false) }
  it { should have_one(:contract).dependent(:nullify) }
end

# Test::Unit
class PersonTest < ActiveSupport::TestCase
  should have_one(:partner)
  should have_one(:life).through(:partner)
  should have_one(:car).through(:partner).source(:vehicle)
  should have_one(:pet).conditions('weight < 80')
  should have_one(:focus).order('priority desc')
  should have_one(:chance).class_name('Opportunity')
  should have_one(:job).with_foreign_key('worker_id')
  should have_one(:parking_card).validate(false)
  should have_one(:contract).dependent(:nullify)
end
```

#### have_and_belong_to_many

The `have_and_belong_to_many` matcher tests your `has_and_belongs_to_many`
associations.

```ruby
class Person < ActiveRecord::Base
  has_and_belongs_to_many :awards
  has_and_belongs_to_many :issues, -> { where(difficulty: 'hard') }
  has_and_belongs_to_many :projects, -> { order('time_spent') }
  has_and_belongs_to_many :places_visited, class_name: 'City'
  has_and_belongs_to_many :interviews, validate: false
end

# RSpec
describe Person do
  it { should have_and_belong_to_many(:awards) }
  it { should have_and_belong_to_many(:issues).conditions(difficulty: 'hard') }
  it { should have_and_belong_to_many(:projects).order('time_spent') }
  it { should have_and_belong_to_many(:places_visited).class_name('City') }
  it { should have_and_belong_to_many(:interviews).validate(false) }
end

# Test::Unit
class PersonTest < ActiveSupport::TestCase
  should have_and_belong_to_many(:awards)
  should have_and_belong_to_many(:issues).conditions(difficulty: 'hard')
  should have_and_belong_to_many(:projects).order('time_spent')
  should have_and_belong_to_many(:places_visited).class_name('City')
  should have_and_belong_to_many(:interviews).validate(false)
end
```

#### have_db_column

The `have_db_column` matcher tests that the table that backs your model
has a specific column.

```ruby
class CreatePhones < ActiveRecord::Migration
  def change
    create_table :phones do |t|
      t.decimal :supported_ios_version
      t.string :model, null: false
      t.decimal :camera_aperture, precision: 1
    end
  end
end

# RSpec
describe Phone do
  it { should have_db_column(:supported_ios_version) }
  it { should have_db_column(:model).with_options(null: false) }

  it do
    should have_db_column(:camera_aperture).
      of_type(:decimal).
      with_options(precision: 1)
  end
end

# Test::Unit
class PhoneTest < ActiveSupport::TestCase
  should have_db_column(:supported_ios_version)
  should have_db_column(:model).with_options(null: false)

  should have_db_column(:camera_aperture).
    of_type(:decimal).
    with_options(precision: 1)
end
```

#### have_db_index

The `have_db_index` matcher tests that the table that backs your model has a
index on a specific column.

```ruby
class CreateBlogs < ActiveRecord::Migration
  def change
    create_table :blogs do |t|
      t.integer :user_id, null: false
      t.string :name, null: false
    end

    add_index :blogs, :user_id
    add_index :blogs, :name, unique: true
  end
end

# RSpec
describe Blog do
  it { should have_db_index(:user_id) }
  it { should have_db_index(:name).unique(true) }
end

# Test::Unit
class BlogTest < ActiveSupport::TestCase
  should have_db_index(:user_id)
  should have_db_index(:name).unique(true)
end
```

#### have_readonly_attribute

The `have_readonly_attribute` matcher tests usage of the `attr_readonly` macro.

```ruby
class User < ActiveRecord::Base
  attr_readonly :password
end

# RSpec
describe User do
  it { should have_readonly_attribute(:password) }
end

# Test::Unit
class UserTest < ActiveSupport::TestCase
  should have_readonly_attribute(:password)
end
```

#### serialize

The `serialize` matcher tests usage of the `serialize` macro.

```ruby
class ProductOptionsSerializer
  def load(string)
    # ...
  end

  def dump(options)
    # ...
  end
end

class Product < ActiveRecord::Base
  serialize :customizations
  serialize :specifications, ProductSpecsSerializer
  serialize :options, ProductOptionsSerializer.new
end

# RSpec
describe Product do
  it { should serialize(:customizations) }
  it { should serialize(:specifications).as(ProductSpecsSerializer) }
  it { should serialize(:options).as_instance_of(ProductOptionsSerializer) }
end

# Test::Unit
class ProductTest < ActiveSupport::TestCase
  should serialize(:customizations)
  should serialize(:specifications).as(ProductSpecsSerializer)
  should serialize(:options).as_instance_of(ProductOptionsSerializer)
end
```

### ActionController Matchers

*Jump to: [filter_param](#filter_param), [permit](#permit), [redirect_to](#redirect_to), [render_template](#render_template), [render_with_layout](#render_with_layout), [rescue_from](#rescue_from), [respond_with](#respond_with), [route](#route), [set_session](#set_session), [set_the_flash](#set_the_flash), [use_after_filter / use_after_action](#use_after_filter--use_after_action), [use_around_filter / use_around_action](#use_around_filter--use_around_action), [use_before_filter / use_around_action](#use_before_filter--use_before_action)*

#### filter_param

The `filter_param` matcher tests parameter filtering configuration.

```ruby
class MyApplication < Rails::Application
  config.filter_parameters << :secret_key
end

# RSpec
describe ApplicationController do
  it { should filter_param(:secret_key) }
end

# Test::Unit
class ApplicationControllerTest < ActionController::TestCase
  should filter_param(:secret_key)
end
```

#### permit

The `permit` matcher tests that only whitelisted parameters are permitted.

```ruby
class UserController < ActionController::Base
  def create
    User.create(user_params)
  end

  private

  def user_params
    params.require(:user).permit(:email)
  end
end

# RSpec
describe UserController do
  it { should permit(:email).for(:create) }
end

# Test::Unit
class UserControllerTest < ActionController::TestCase
  should permit(:email).for(:create)
end
```

#### redirect_to

The `redirect_to` matcher tests that an action redirects to a certain location.
In a test suite using RSpec, it is very similar to rspec-rails's `redirect_to`
matcher. In a test suite using Test::Unit / Shoulda, it provides a more
expressive syntax over `assert_redirected_to`.

```ruby
class PostsController < ApplicationController
  def show
    redirect_to :index
  end
end

# RSpec
describe PostsController do
  describe 'GET #list' do
    before { get :list }

    it { should redirect_to(posts_path) }
  end
end

# Test::Unit
class PostsControllerTest < ActionController::TestCase
  context 'GET #list' do
    setup { get :list }

    should redirect_to { posts_path }
  end
end
```

#### render_template

The `render_template` matcher tests that an action renders a template.
In RSpec, it is very similar to rspec-rails's `render_template` matcher.
In Test::Unit, it provides a more expressive syntax over `assert_template`.

```ruby
class PostsController < ApplicationController
  def show
  end
end

# RSpec
describe PostsController do
  describe 'GET #show' do
    before { get :show }

    it { should render_template('show') }
  end
end

# Test::Unit
class PostsControllerTest < ActionController::TestCase
  context 'GET #show' do
    setup { get :show }

    should render_template('show')
  end
end
```

#### render_with_layout

The `render_with_layout` matcher tests that an action is rendered with a certain
layout.

```ruby
class PostsController < ApplicationController
  def show
    render layout: 'posts'
  end
end

# RSpec
describe PostsController do
  describe 'GET #show' do
    before { get :show }

    it { should render_with_layout('posts') }
  end
end

# Test::Unit
class PostsControllerTest < ActionController::TestCase
  context 'GET #show' do
    setup { get :show }

    should render_with_layout('posts')
  end
end
```

#### rescue_from

The `rescue_from` matcher tests usage of the `rescue_from` macro.

```ruby
class ApplicationController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found

  private

  def handle_not_found
    # ...
  end
end

# RSpec
describe ApplicationController do
  it do
    should rescue_from(ActiveRecord::RecordNotFound).
      with(:handle_not_found)
  end
end

# Test::Unit
class ApplicationControllerTest < ActionController::TestCase
  should rescue_from(ActiveRecord::RecordNotFound).
    with(:handle_not_found)
end
```

#### respond_with

The `respond_with` matcher tests that an action responds with a certain status
code.

```ruby
class PostsController < ApplicationController
  def index
    render status: 403
  end

  def show
    render status: :locked
  end

  def destroy
    render status: 508
  end
end

# RSpec
describe PostsController do
  describe 'GET #index' do
    before { get :index }

    it { should respond_with(403) }
  end

  describe 'GET #show' do
    before { get :show }

    it { should respond_with(:locked) }
  end

  describe 'DELETE #destroy' do
    before { delete :destroy }

    it { should respond_with(500..600) }
  end
end

# Test::Unit
class PostsControllerTest < ActionController::TestCase
  context 'GET #index' do
    setup { get :index }

    should respond_with(403)
  end

  context 'GET #show' do
    setup { get :show }

    should respond_with(:locked)
  end

  context 'DELETE #destroy' do
    setup { delete :destroy }

    should respond_with(500..600)
  end
end
```

#### route

The `route` matcher tests that a route resolves to a controller, action, and
params; and that the controller, action, and params generates the same route. For
an RSpec suite, this is like using a combination of `route_to` and
`be_routable`. For a Test::Unit suite, it provides a more expressive syntax
over `assert_routing`.

```ruby
My::Application.routes.draw do
  get '/posts', controller: 'posts', action: 'index'
  get '/posts/:id' => 'posts#show'
end

# RSpec
describe 'Routing' do
  it { should route(:get, '/posts').to(controller: 'posts', action: 'index') }
  it { should route(:get, '/posts/1').to('posts#show', id: 1) }
end

# Test::Unit
class RoutesTest < ActionController::IntegrationTest
  should route(:get, '/posts').to(controller: 'posts', action: 'index')
  should route(:get, '/posts/1').to('posts#show', id: 1)
end
```

#### set_session

The `set_session` matcher asserts that a key in the `session` hash has been set
to a certain value.

```ruby
class PostsController < ApplicationController
  def show
    session[:foo] = 'bar'
  end
end

# RSpec
describe PostsController do
  describe 'GET #show' do
    before { get :show }

    it { should set_session(:foo).to('bar') }
    it { should_not set_session(:baz) }
  end
end

# Test::Unit
class PostsControllerTest < ActionController::TestCase
  context 'GET #show' do
    setup { get :show }

    should set_session(:foo).to('bar')
    should_not set_session(:baz)
  end
end
```

#### set_the_flash

The `set_the_flash` matcher asserts that a key in the `flash` hash is set to a
certain value.

```ruby
class PostsController < ApplicationController
  def index
    flash[:foo] = 'A candy bar'
  end

  def show
    flash.now[:foo] = 'bar'
  end

  def destroy
  end
end

# RSpec
describe PostsController do
  describe 'GET #index' do
    before { get :index }

    it { should set_the_flash.to('bar') }
    it { should set_the_flash.to(/bar/) }
    it { should set_the_flash[:foo].to('bar') }
    it { should_not set_the_flash[:baz] }
  end

  describe 'GET #show' do
    before { get :show }

    it { should set_the_flash.now }
    it { should set_the_flash[:foo].now }
    it { should set_the_flash[:foo].to('bar').now }
  end

  describe 'DELETE #destroy' do
    before { delete :destroy }

    it { should_not set_the_flash }
  end
end

# Test::Unit
class PostsControllerTest < ActionController::TestCase
  context 'GET #index' do
    setup { get :index }

    should set_the_flash.to('bar')
    should set_the_flash.to(/bar/)
    should set_the_flash[:foo].to('bar')
    should_not set_the_flash[:baz]
  end

  context 'GET #show' do
    setup { get :show }

    should set_the_flash.now
    should set_the_flash[:foo].now
    should set_the_flash[:foo].to('bar').now
  end

  context 'DELETE #destroy' do
    setup { delete :destroy }

    should_not set_the_flash
  end
end
```

#### use_after_filter / use_after_action

The `use_after_filter` ensures a given `after_filter` is used. This is also
available as `use_after_action` to provide Rails 4 support.

```ruby
class UserController < ActionController::Base
  after_filter :log_activity
end

# RSpec
describe UserController do
  it { should use_after_filter(:log_activity) }
end

# Test::Unit
class UserControllerTest < ActionController::TestCase
  should use_after_filter(:log_activity)
end
```

#### use_around_filter / use_around_action

The `use_around_filter` ensures a given `around_filter` is used. This is also
available as `use_around_action` to provide Rails 4 support.

```ruby
class UserController < ActionController::Base
  around_filter :log_activity
end

# RSpec
describe UserController do
  it { should use_around_filter(:log_activity) }
end

# Test::Unit
class UserControllerTest < ActionController::TestCase
  should use_around_filter(:log_activity)
end
```

#### use_before_filter / use_before_action

The `use_before_filter` ensures a given `before_filter` is used. This is also
available as `use_before_action` for Rails 4 support.

```ruby
class UserController < ActionController::Base
  before_filter :authenticate_user!
end

# RSpec
describe UserController do
  it { should use_before_filter(:authenticate_user!) }
end

# Test::Unit
class UserControllerTest < ActionController::TestCase
  should use_before_filter(:authenticate_user!)
end
```

## Independent Matchers

Matchers to test non-Rails-dependent code:

#### delegate_method

```ruby
class Human < ActiveRecord::Base
  has_one :robot
  delegate :work, to: :robot

  # alternatively, if you are not using Rails
  def work
    robot.work
  end

  def protect
    robot.protect('Sarah Connor')
  end

  def speak
    robot.beep_boop
  end
end

# RSpec
describe Human do
  it { should delegate_method(:work).to(:robot) }
  it { should delegate_method(:protect).to(:robot).with_arguments('Sarah Connor') }
  it { should delegate_method(:beep_boop).to(:robot).as(:speak) }
end

# Test::Unit
class HumanTest < ActiveSupport::TestCase
  should delegate_method(:work).to(:robot)
  should delegate_method(:protect).to(:robot).with_arguments('Sarah Connor')
  should delegate_method(:beep_boop).to(:robot).as(:speak)
end
```

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

[fury-badge]: https://badge.fury.io/rb/shoulda-matchers.png
[fury]: http://badge.fury.io/rb/shoulda-matchers
[travis-badge]: https://secure.travis-ci.org/thoughtbot/shoulda-matchers.png?branch=master
[travis]: http://travis-ci.org/thoughtbot/shoulda-matchers
[rubydocs]: http://rubydoc.info/github/thoughtbot/shoulda-matchers/master/frames
[community]: http://thoughtbot.com/community
[contributors]: https://github.com/thoughtbot/shoulda-matchers/contributors
