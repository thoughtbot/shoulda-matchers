require 'active_support/core_ext/module/delegation'

module Shoulda
  module Matchers
    module ActiveRecord
      # The `belong_to` matcher is used to ensure that a `belong_to` association
      # exists on your model.
      #
      #     class Person < ActiveRecord::Base
      #       belongs_to :organization
      #     end
      #
      #     # RSpec
      #     RSpec.describe Person, type: :model do
      #       it { should belong_to(:organization) }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class PersonTest < ActiveSupport::TestCase
      #       should belong_to(:organization)
      #     end
      #
      # Note that polymorphic associations are automatically detected and do not
      # need any qualifiers:
      #
      #     class Comment < ActiveRecord::Base
      #       belongs_to :commentable, polymorphic: true
      #     end
      #
      #     # RSpec
      #     RSpec.describe Comment, type: :model do
      #       it { should belong_to(:commentable) }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class CommentTest < ActiveSupport::TestCase
      #       should belong_to(:commentable)
      #     end
      #
      # #### Qualifiers
      #
      # ##### conditions
      #
      # Use `conditions` if your association is defined with a scope that sets
      # the `where` clause.
      #
      #     class Person < ActiveRecord::Base
      #       belongs_to :family, -> { where(everyone_is_perfect: false) }
      #     end
      #
      #     # RSpec
      #     RSpec.describe Person, type: :model do
      #       it do
      #         should belong_to(:family).
      #           conditions(everyone_is_perfect: false)
      #       end
      #     end
      #
      #     # Minitest (Shoulda)
      #     class PersonTest < ActiveSupport::TestCase
      #       should belong_to(:family).
      #         conditions(everyone_is_perfect: false)
      #     end
      #
      # ##### order
      #
      # Use `order` if your association is defined with a scope that sets the
      # `order` clause.
      #
      #     class Person < ActiveRecord::Base
      #       belongs_to :previous_company, -> { order('hired_on desc') }
      #     end
      #
      #     # RSpec
      #     RSpec.describe Person, type: :model do
      #       it { should belong_to(:previous_company).order('hired_on desc') }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class PersonTest < ActiveSupport::TestCase
      #       should belong_to(:previous_company).order('hired_on desc')
      #     end
      #
      # ##### class_name
      #
      # Use `class_name` to test usage of the `:class_name` option. This
      # asserts that the model you're referring to actually exists.
      #
      #     class Person < ActiveRecord::Base
      #       belongs_to :ancient_city, class_name: 'City'
      #     end
      #
      #     # RSpec
      #     RSpec.describe Person, type: :model do
      #       it { should belong_to(:ancient_city).class_name('City') }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class PersonTest < ActiveSupport::TestCase
      #       should belong_to(:ancient_city).class_name('City')
      #     end
      #
      # ##### with_primary_key
      #
      # Use `with_primary_key` to test usage of the `:primary_key` option.
      #
      #     class Person < ActiveRecord::Base
      #       belongs_to :great_country, primary_key: 'country_id'
      #     end
      #
      #     # RSpec
      #     RSpec.describe Person, type: :model do
      #       it do
      #         should belong_to(:great_country).
      #           with_primary_key('country_id')
      #       end
      #     end
      #
      #     # Minitest (Shoulda)
      #     class PersonTest < ActiveSupport::TestCase
      #       should belong_to(:great_country).
      #         with_primary_key('country_id')
      #     end
      #
      # ##### with_foreign_key
      #
      # Use `with_foreign_key` to test usage of the `:foreign_key` option.
      #
      #     class Person < ActiveRecord::Base
      #       belongs_to :great_country, foreign_key: 'country_id'
      #     end
      #
      #     # RSpec
      #     RSpec.describe Person, type: :model do
      #       it do
      #         should belong_to(:great_country).
      #           with_foreign_key('country_id')
      #       end
      #     end
      #
      #     # Minitest (Shoulda)
      #     class PersonTest < ActiveSupport::TestCase
      #       should belong_to(:great_country).
      #         with_foreign_key('country_id')
      #     end
      #
      # ##### dependent
      #
      # Use `dependent` to assert that the `:dependent` option was specified.
      #
      #     class Person < ActiveRecord::Base
      #       belongs_to :world, dependent: :destroy
      #     end
      #
      #     # RSpec
      #     RSpec.describe Person, type: :model do
      #       it { should belong_to(:world).dependent(:destroy) }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class PersonTest < ActiveSupport::TestCase
      #       should belong_to(:world).dependent(:destroy)
      #     end
      #
      # To assert that *any* `:dependent` option was specified, use `true`:
      #
      #     # RSpec
      #     RSpec.describe Person, type: :model do
      #       it { should belong_to(:world).dependent(true) }
      #     end
      #
      # To assert that *no* `:dependent` option was specified, use `false`:
      #
      #     class Person < ActiveRecord::Base
      #       belongs_to :company
      #     end
      #
      #     # RSpec
      #     RSpec.describe Person, type: :model do
      #       it { should belong_to(:company).dependent(false) }
      #     end
      #
      # ##### counter_cache
      #
      # Use `counter_cache` to assert that the `:counter_cache` option was
      # specified.
      #
      #     class Person < ActiveRecord::Base
      #       belongs_to :organization, counter_cache: true
      #     end
      #
      #     # RSpec
      #     RSpec.describe Person, type: :model do
      #       it { should belong_to(:organization).counter_cache(true) }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class PersonTest < ActiveSupport::TestCase
      #       should belong_to(:organization).counter_cache(true)
      #     end
      #
      # ##### touch
      #
      # Use `touch` to assert that the `:touch` option was specified.
      #
      #     class Person < ActiveRecord::Base
      #       belongs_to :organization, touch: true
      #     end
      #
      #     # RSpec
      #     RSpec.describe Person, type: :model do
      #       it { should belong_to(:organization).touch(true) }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class PersonTest < ActiveSupport::TestCase
      #       should belong_to(:organization).touch(true)
      #     end
      #
      # #### autosave
      #
      # Use `autosave` to assert that the `:autosave` option was specified.
      #
      #     class Account < ActiveRecord::Base
      #       belongs_to :bank, autosave: true
      #     end
      #
      #     # RSpec
      #     RSpec.describe Account, type: :model do
      #       it { should belong_to(:bank).autosave(true) }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class AccountTest < ActiveSupport::TestCase
      #       should belong_to(:bank).autosave(true)
      #     end
      #
      # ##### inverse_of
      #
      # Use `inverse_of` to assert that the `:inverse_of` option was specified.
      #
      #     class Person < ActiveRecord::Base
      #       belongs_to :organization, inverse_of: :employees
      #     end
      #
      #     # RSpec
      #     describe Person
      #       it { should belong_to(:organization).inverse_of(:employees) }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class PersonTest < ActiveSupport::TestCase
      #       should belong_to(:organization).inverse_of(:employees)
      #     end
      #
      # @return [AssociationMatcher]
      #
      def belong_to(name)
        AssociationMatcher.new(:belongs_to, name)
      end

      # The `have_many` matcher is used to test that a `has_many` or `has_many
      # :through` association exists on your model.
      #
      #     class Person < ActiveRecord::Base
      #       has_many :friends
      #     end
      #
      #     # RSpec
      #     RSpec.describe Person, type: :model do
      #       it { should have_many(:friends) }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class PersonTest < ActiveSupport::TestCase
      #       should have_many(:friends)
      #     end
      #
      # Note that polymorphic associations are automatically detected and do not
      # need any qualifiers:
      #
      #     class Person < ActiveRecord::Base
      #       has_many :pictures, as: :imageable
      #     end
      #
      #     # RSpec
      #     RSpec.describe Person, type: :model do
      #       it { should have_many(:pictures) }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class PersonTest < ActiveSupport::TestCase
      #       should have_many(:pictures)
      #     end
      #
      # #### Qualifiers
      #
      # ##### conditions
      #
      # Use `conditions` if your association is defined with a scope that sets
      # the `where` clause.
      #
      #     class Person < ActiveRecord::Base
      #       has_many :coins, -> { where(quality: 'mint') }
      #     end
      #
      #     # RSpec
      #     RSpec.describe Person, type: :model do
      #       it { should have_many(:coins).conditions(quality: 'mint') }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class PersonTest < ActiveSupport::TestCase
      #       should have_many(:coins).conditions(quality: 'mint')
      #     end
      #
      # ##### order
      #
      # Use `order` if your association is defined with a scope that sets the
      # `order` clause.
      #
      #     class Person < ActiveRecord::Base
      #       has_many :shirts, -> { order('color') }
      #     end
      #
      #     # RSpec
      #     RSpec.describe Person, type: :model do
      #       it { should have_many(:shirts).order('color') }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class PersonTest < ActiveSupport::TestCase
      #       should have_many(:shirts).order('color')
      #     end
      #
      # ##### class_name
      #
      # Use `class_name` to test usage of the `:class_name` option. This
      # asserts that the model you're referring to actually exists.
      #
      #     class Person < ActiveRecord::Base
      #       has_many :hopes, class_name: 'Dream'
      #     end
      #
      #     # RSpec
      #     RSpec.describe Person, type: :model do
      #       it { should have_many(:hopes).class_name('Dream') }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class PersonTest < ActiveSupport::TestCase
      #       should have_many(:hopes).class_name('Dream')
      #     end
      #
      # ##### with_primary_key
      #
      # Use `with_primary_key` to test usage of the `:primary_key` option.
      #
      #     class Person < ActiveRecord::Base
      #       has_many :worries, primary_key: 'worrier_id'
      #     end
      #
      #     # RSpec
      #     RSpec.describe Person, type: :model do
      #       it { should have_many(:worries).with_primary_key('worrier_id') }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class PersonTest < ActiveSupport::TestCase
      #       should have_many(:worries).with_primary_key('worrier_id')
      #     end
      #
      # ##### with_foreign_key
      #
      # Use `with_foreign_key` to test usage of the `:foreign_key` option.
      #
      #     class Person < ActiveRecord::Base
      #       has_many :worries, foreign_key: 'worrier_id'
      #     end
      #
      #     # RSpec
      #     RSpec.describe Person, type: :model do
      #       it { should have_many(:worries).with_foreign_key('worrier_id') }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class PersonTest < ActiveSupport::TestCase
      #       should have_many(:worries).with_foreign_key('worrier_id')
      #     end
      #
      # ##### dependent
      #
      # Use `dependent` to assert that the `:dependent` option was specified.
      #
      #     class Person < ActiveRecord::Base
      #       has_many :secret_documents, dependent: :destroy
      #     end
      #
      #     # RSpec
      #     RSpec.describe Person, type: :model do
      #       it { should have_many(:secret_documents).dependent(:destroy) }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class PersonTest < ActiveSupport::TestCase
      #       should have_many(:secret_documents).dependent(:destroy)
      #     end
      #
      # ##### through
      #
      # Use `through` to test usage of the `:through` option. This asserts that
      # the association you are going through actually exists.
      #
      #     class Person < ActiveRecord::Base
      #       has_many :acquaintances, through: :friends
      #     end
      #
      #     # RSpec
      #     RSpec.describe Person, type: :model do
      #       it { should have_many(:acquaintances).through(:friends) }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class PersonTest < ActiveSupport::TestCase
      #       should have_many(:acquaintances).through(:friends)
      #     end
      #
      # ##### source
      #
      # Use `source` to test usage of the `:source` option on a `:through`
      # association.
      #
      #     class Person < ActiveRecord::Base
      #       has_many :job_offers, through: :friends, source: :opportunities
      #     end
      #
      #     # RSpec
      #     RSpec.describe Person, type: :model do
      #       it do
      #         should have_many(:job_offers).
      #           through(:friends).
      #           source(:opportunities)
      #       end
      #     end
      #
      #     # Minitest (Shoulda)
      #     class PersonTest < ActiveSupport::TestCase
      #       should have_many(:job_offers).
      #         through(:friends).
      #         source(:opportunities)
      #     end
      #
      # ##### validate
      #
      # Use `validate` to assert that the `:validate` option was specified.
      #
      #     class Person < ActiveRecord::Base
      #       has_many :ideas, validate: false
      #     end
      #
      #     # RSpec
      #     RSpec.describe Person, type: :model do
      #       it { should have_many(:ideas).validate(false) }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class PersonTest < ActiveSupport::TestCase
      #       should have_many(:ideas).validate(false)
      #     end
      #
      # #### autosave
      #
      # Use `autosave` to assert that the `:autosave` option was specified.
      #
      #     class Player < ActiveRecord::Base
      #       has_many :games, autosave: true
      #     end
      #
      #     # RSpec
      #     RSpec.describe Player, type: :model do
      #       it { should have_many(:games).autosave(true) }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class PlayerTest < ActiveSupport::TestCase
      #       should have_many(:games).autosave(true)
      #     end
      #
      # ##### inverse_of
      #
      # Use `inverse_of` to assert that the `:inverse_of` option was specified.
      #
      #     class Organization < ActiveRecord::Base
      #       has_many :employees, inverse_of: :company
      #     end
      #
      #     # RSpec
      #     describe Organization
      #       it { should have_many(:employees).inverse_of(:company) }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class OrganizationTest < ActiveSupport::TestCase
      #       should have_many(:employees).inverse_of(:company)
      #     end
      #
      # @return [AssociationMatcher]
      #
      def have_many(name)
        AssociationMatcher.new(:has_many, name)
      end

      # The `have_one` matcher is used to test that a `has_one` or `has_one
      # :through` association exists on your model.
      #
      #     class Person < ActiveRecord::Base
      #       has_one :partner
      #     end
      #
      #     # RSpec
      #     RSpec.describe Person, type: :model do
      #       it { should have_one(:partner) }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class PersonTest < ActiveSupport::TestCase
      #       should have_one(:partner)
      #     end
      #
      # #### Qualifiers
      #
      # ##### conditions
      #
      # Use `conditions` if your association is defined with a scope that sets
      # the `where` clause.
      #
      #     class Person < ActiveRecord::Base
      #       has_one :pet, -> { where('weight < 80') }
      #     end
      #
      #     # RSpec
      #     RSpec.describe Person, type: :model do
      #       it { should have_one(:pet).conditions('weight < 80') }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class PersonTest < ActiveSupport::TestCase
      #       should have_one(:pet).conditions('weight < 80')
      #     end
      #
      # ##### order
      #
      # Use `order` if your association is defined with a scope that sets the
      # `order` clause.
      #
      #     class Person < ActiveRecord::Base
      #       has_one :focus, -> { order('priority desc') }
      #     end
      #
      #     # RSpec
      #     RSpec.describe Person, type: :model do
      #       it { should have_one(:focus).order('priority desc') }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class PersonTest < ActiveSupport::TestCase
      #       should have_one(:focus).order('priority desc')
      #     end
      #
      # ##### class_name
      #
      # Use `class_name` to test usage of the `:class_name` option. This
      # asserts that the model you're referring to actually exists.
      #
      #     class Person < ActiveRecord::Base
      #       has_one :chance, class_name: 'Opportunity'
      #     end
      #
      #     # RSpec
      #     RSpec.describe Person, type: :model do
      #       it { should have_one(:chance).class_name('Opportunity') }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class PersonTest < ActiveSupport::TestCase
      #       should have_one(:chance).class_name('Opportunity')
      #     end
      #
      # ##### dependent
      #
      # Use `dependent` to test that the `:dependent` option was specified.
      #
      #     class Person < ActiveRecord::Base
      #       has_one :contract, dependent: :nullify
      #     end
      #
      #     # RSpec
      #     RSpec.describe Person, type: :model do
      #       it { should have_one(:contract).dependent(:nullify) }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class PersonTest < ActiveSupport::TestCase
      #       should have_one(:contract).dependent(:nullify)
      #     end
      #
      # ##### with_primary_key
      #
      # Use `with_primary_key` to test usage of the `:primary_key` option.
      #
      #     class Person < ActiveRecord::Base
      #       has_one :job, primary_key: 'worker_id'
      #     end
      #
      #     # RSpec
      #     RSpec.describe Person, type: :model do
      #       it { should have_one(:job).with_primary_key('worker_id') }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class PersonTest < ActiveSupport::TestCase
      #       should have_one(:job).with_primary_key('worker_id')
      #     end
      #
      # ##### with_foreign_key
      #
      # Use `with_foreign_key` to test usage of the `:foreign_key` option.
      #
      #     class Person < ActiveRecord::Base
      #       has_one :job, foreign_key: 'worker_id'
      #     end
      #
      #     # RSpec
      #     RSpec.describe Person, type: :model do
      #       it { should have_one(:job).with_foreign_key('worker_id') }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class PersonTest < ActiveSupport::TestCase
      #       should have_one(:job).with_foreign_key('worker_id')
      #     end
      #
      # ##### through
      #
      # Use `through` to test usage of the `:through` option. This asserts that
      # the association you are going through actually exists.
      #
      #     class Person < ActiveRecord::Base
      #       has_one :life, through: :partner
      #     end
      #
      #     # RSpec
      #     RSpec.describe Person, type: :model do
      #       it { should have_one(:life).through(:partner) }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class PersonTest < ActiveSupport::TestCase
      #       should have_one(:life).through(:partner)
      #     end
      #
      # ##### source
      #
      # Use `source` to test usage of the `:source` option on a `:through`
      # association.
      #
      #     class Person < ActiveRecord::Base
      #       has_one :car, through: :partner, source: :vehicle
      #     end
      #
      #     # RSpec
      #     RSpec.describe Person, type: :model do
      #       it { should have_one(:car).through(:partner).source(:vehicle) }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class PersonTest < ActiveSupport::TestCase
      #       should have_one(:car).through(:partner).source(:vehicle)
      #     end
      #
      # ##### validate
      #
      # Use `validate` to assert that the the `:validate` option was specified.
      #
      #     class Person < ActiveRecord::Base
      #       has_one :parking_card, validate: false
      #     end
      #
      #     # RSpec
      #     RSpec.describe Person, type: :model do
      #       it { should have_one(:parking_card).validate(false) }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class PersonTest < ActiveSupport::TestCase
      #       should have_one(:parking_card).validate(false)
      #     end
      #
      # #### autosave
      #
      # Use `autosave` to assert that the `:autosave` option was specified.
      #
      #     class Account < ActiveRecord::Base
      #       has_one :bank, autosave: true
      #     end
      #
      #     # RSpec
      #     RSpec.describe Account, type: :model do
      #       it { should have_one(:bank).autosave(true) }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class AccountTest < ActiveSupport::TestCase
      #       should have_one(:bank).autosave(true)
      #     end
      #
      # @return [AssociationMatcher]
      #
      def have_one(name)
        AssociationMatcher.new(:has_one, name)
      end

      # The `have_and_belong_to_many` matcher is used to test that a
      # `has_and_belongs_to_many` association exists on your model and that the
      # join table exists in the database.
      #
      #     class Person < ActiveRecord::Base
      #       has_and_belongs_to_many :awards
      #     end
      #
      #     # RSpec
      #     RSpec.describe Person, type: :model do
      #       it { should have_and_belong_to_many(:awards) }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class PersonTest < ActiveSupport::TestCase
      #       should have_and_belong_to_many(:awards)
      #     end
      #
      # #### Qualifiers
      #
      # ##### conditions
      #
      # Use `conditions` if your association is defined with a scope that sets
      # the `where` clause.
      #
      #     class Person < ActiveRecord::Base
      #       has_and_belongs_to_many :issues, -> { where(difficulty: 'hard') }
      #     end
      #
      #     # RSpec
      #     RSpec.describe Person, type: :model do
      #       it do
      #         should have_and_belong_to_many(:issues).
      #           conditions(difficulty: 'hard')
      #       end
      #     end
      #
      #     # Minitest (Shoulda)
      #     class PersonTest < ActiveSupport::TestCase
      #       should have_and_belong_to_many(:issues).
      #         conditions(difficulty: 'hard')
      #     end
      #
      # ##### order
      #
      # Use `order` if your association is defined with a scope that sets the
      # `order` clause.
      #
      #     class Person < ActiveRecord::Base
      #       has_and_belongs_to_many :projects, -> { order('time_spent') }
      #     end
      #
      #     # RSpec
      #     RSpec.describe Person, type: :model do
      #       it do
      #         should have_and_belong_to_many(:projects).
      #           order('time_spent')
      #       end
      #     end
      #
      #     # Minitest (Shoulda)
      #     class PersonTest < ActiveSupport::TestCase
      #       should have_and_belong_to_many(:projects).
      #         order('time_spent')
      #     end
      #
      # ##### class_name
      #
      # Use `class_name` to test usage of the `:class_name` option. This
      # asserts that the model you're referring to actually exists.
      #
      #     class Person < ActiveRecord::Base
      #       has_and_belongs_to_many :places_visited, class_name: 'City'
      #     end
      #
      #     # RSpec
      #     RSpec.describe Person, type: :model do
      #       it do
      #         should have_and_belong_to_many(:places_visited).
      #           class_name('City')
      #       end
      #     end
      #
      #     # Minitest (Shoulda)
      #     class PersonTest < ActiveSupport::TestCase
      #       should have_and_belong_to_many(:places_visited).
      #         class_name('City')
      #     end
      #
      # ##### join_table
      #
      # Use `join_table` to test usage of the `:join_table` option. This
      # asserts that the table you're referring to actually exists.
      #
      #     class Person < ActiveRecord::Base
      #       has_and_belongs_to_many :issues, join_table: 'people_tickets'
      #     end
      #
      #     # RSpec
      #     RSpec.describe Person, type: :model do
      #       it do
      #         should have_and_belong_to_many(:issues).
      #           join_table('people_tickets')
      #       end
      #     end
      #
      #     # Minitest (Shoulda)
      #     class PersonTest < ActiveSupport::TestCase
      #       should have_and_belong_to_many(:issues).
      #         join_table('people_tickets')
      #     end
      #
      # ##### validate
      #
      # Use `validate` to test that the `:validate` option was specified.
      #
      #     class Person < ActiveRecord::Base
      #       has_and_belongs_to_many :interviews, validate: false
      #     end
      #
      #     # RSpec
      #     RSpec.describe Person, type: :model do
      #       it do
      #         should have_and_belong_to_many(:interviews).
      #           validate(false)
      #       end
      #     end
      #
      #     # Minitest (Shoulda)
      #     class PersonTest < ActiveSupport::TestCase
      #       should have_and_belong_to_many(:interviews).
      #         validate(false)
      #     end
      #
      # #### autosave
      #
      # Use `autosave` to assert that the `:autosave` option was specified.
      #
      #     class Publisher < ActiveRecord::Base
      #       has_and_belongs_to_many :advertisers, autosave: true
      #     end
      #
      #     # RSpec
      #     RSpec.describe Publisher, type: :model do
      #       it { should have_and_belong_to_many(:advertisers).autosave(true) }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class AccountTest < ActiveSupport::TestCase
      #       should have_and_belong_to_many(:advertisers).autosave(true)
      #     end
      #
      # @return [AssociationMatcher]
      #
      def have_and_belong_to_many(name)
        AssociationMatcher.new(:has_and_belongs_to_many, name)
      end

      # @private
      class AssociationMatcher
        delegate :reflection, :model_class, :associated_class, :through?,
          :polymorphic?, to: :reflector

        attr_reader :name, :options

        def initialize(macro, name)
          @macro = macro
          @name = name
          @options = {}
          @submatchers = []
          @missing = ''
        end

        def through(through)
          through_matcher = AssociationMatchers::ThroughMatcher.new(through, name)
          add_submatcher(through_matcher)
          self
        end

        def dependent(dependent)
          dependent_matcher = AssociationMatchers::DependentMatcher.new(dependent, name)
          add_submatcher(dependent_matcher)
          self
        end

        def order(order)
          order_matcher = AssociationMatchers::OrderMatcher.new(order, name)
          add_submatcher(order_matcher)
          self
        end

        def counter_cache(counter_cache = true)
          counter_cache_matcher = AssociationMatchers::CounterCacheMatcher.new(counter_cache, name)
          add_submatcher(counter_cache_matcher)
          self
        end

        def inverse_of(inverse_of)
          inverse_of_matcher =
            AssociationMatchers::InverseOfMatcher.new(inverse_of, name)
          add_submatcher(inverse_of_matcher)
          self
        end

        def source(source)
          source_matcher = AssociationMatchers::SourceMatcher.new(source, name)
          add_submatcher(source_matcher)
          self
        end

        def conditions(conditions)
          @options[:conditions] = conditions
          self
        end

        def autosave(autosave)
          @options[:autosave] = autosave
          self
        end

        def class_name(class_name)
          @options[:class_name] = class_name
          self
        end

        def with_foreign_key(foreign_key)
          @options[:foreign_key] = foreign_key
          self
        end

        def with_primary_key(primary_key)
          @options[:primary_key] = primary_key
          self
        end

        def validate(validate = true)
          @options[:validate] = validate
          self
        end

        def touch(touch = true)
          @options[:touch] = touch
          self
        end

        def join_table(join_table_name)
          @options[:join_table_name] = join_table_name
          self
        end

        def description
          description = "#{macro_description} #{name}"
          description += " class_name => #{options[:class_name]}" if options.key?(:class_name)
          [description, submatchers.map(&:description)].flatten.join(' ')
        end

        def failure_message
          "Expected #{expectation} (#{missing_options})"
        end

        def failure_message_when_negated
          "Did not expect #{expectation}"
        end

        def matches?(subject)
          @subject = subject
          association_exists? &&
            macro_correct? &&
            (polymorphic? || class_exists?) &&
            foreign_key_exists? &&
            primary_key_exists? &&
            class_name_correct? &&
            join_table_correct? &&
            autosave_correct? &&
            conditions_correct? &&
            validate_correct? &&
            touch_correct? &&
            submatchers_match?
        end

        def join_table_name
          options[:join_table_name] || reflector.join_table_name
        end

        def option_verifier
          @option_verifier ||= AssociationMatchers::OptionVerifier.new(reflector)
        end

        protected

        attr_reader :submatchers, :missing, :subject, :macro

        def reflector
          @reflector ||= AssociationMatchers::ModelReflector.new(subject, name)
        end

        def add_submatcher(matcher)
          @submatchers << matcher
        end

        def macro_description
          case macro.to_s
          when 'belongs_to'
            'belong to'
          when 'has_many'
            'have many'
          when 'has_one'
            'have one'
          when 'has_and_belongs_to_many'
            'have and belong to many'
          end
        end

        def expectation
          "#{model_class.name} to have a #{macro} association called #{name}"
        end

        def missing_options
          missing_options = [missing, missing_options_for_failing_submatchers]
          missing_options.flatten.compact.join(', ')
        end

        def failing_submatchers
          @failing_submatchers ||= submatchers.reject do |matcher|
            matcher.matches?(subject)
          end
        end

        def missing_options_for_failing_submatchers
          if defined?(@failing_submatchers)
            @failing_submatchers.map(&:missing_option)
          else
            []
          end
        end

        def association_exists?
          if reflection.nil?
            @missing = "no association called #{name}"
            false
          else
            true
          end
        end

        def macro_correct?
          if reflection.macro == macro
            true
          elsif reflection.macro == :has_many
            macro == :has_and_belongs_to_many &&
              reflection.name == @name
          else
            @missing = "actual association type was #{reflection.macro}"
            false
          end
        end

        def macro_supports_primary_key?
          macro == :belongs_to ||
            ([:has_many, :has_one].include?(macro) && !through?)
        end

        def foreign_key_exists?
          !(belongs_foreign_key_missing? || has_foreign_key_missing?)
        end

        def primary_key_exists?
          !macro_supports_primary_key? || primary_key_correct?(model_class)
        end

        def belongs_foreign_key_missing?
          macro == :belongs_to && !class_has_foreign_key?(model_class)
        end

        def has_foreign_key_missing?
          [:has_many, :has_one].include?(macro) &&
            !through? &&
            !class_has_foreign_key?(associated_class)
        end

        def class_name_correct?
          if options.key?(:class_name)
            if option_verifier.correct_for_constant?(:class_name, options[:class_name])
              true
            else
              @missing = "#{name} should resolve to #{options[:class_name]} for class_name"
              false
            end
          else
            true
          end
        end

        def join_table_correct?
          if macro != :has_and_belongs_to_many || join_table_matcher.matches?(@subject)
            true
          else
            @missing = join_table_matcher.failure_message
            false
          end
        end

        def join_table_matcher
          @join_table_matcher ||=
            AssociationMatchers::JoinTableMatcher.new(self, reflector)
        end

        def class_exists?
          associated_class
          true
        rescue NameError
          @missing = "#{reflection.class_name} does not exist"
          false
        end

        def autosave_correct?
          if options.key?(:autosave)
            if option_verifier.correct_for_boolean?(:autosave, options[:autosave])
              true
            else
              @missing = "#{name} should have autosave set to #{options[:autosave]}"
              false
            end
          else
            true
          end
        end

        def conditions_correct?
          if options.key?(:conditions)
            if option_verifier.correct_for_relation_clause?(:conditions, options[:conditions])
              true
            else
              @missing = "#{name} should have the following conditions: #{options[:conditions]}"
              false
            end
          else
            true
          end
        end

        def validate_correct?
          if option_verifier.correct_for_boolean?(:validate, options[:validate])
            true
          else
            @missing = "#{name} should have validate: #{options[:validate]}"
            false
          end
        end

        def touch_correct?
          if option_verifier.correct_for_boolean?(:touch, options[:touch])
            true
          else
            @missing = "#{name} should have touch: #{options[:touch]}"
            false
          end
        end

        def class_has_foreign_key?(klass)
          if options.key?(:foreign_key)
            option_verifier.correct_for_string?(:foreign_key, options[:foreign_key])
          else
            if klass.column_names.include?(foreign_key)
              true
            else
              @missing = "#{klass} does not have a #{foreign_key} foreign key."
              false
            end
          end
        end

        def primary_key_correct?(klass)
          if options.key?(:primary_key)
            if option_verifier.correct_for_string?(:primary_key, options[:primary_key])
              true
            else
              @missing = "#{klass} does not have a #{options[:primary_key]} primary key"
              false
            end
          else
            true
          end
        end

        def foreign_key
          if foreign_key_reflection
            if foreign_key_reflection.respond_to?(:foreign_key)
              foreign_key_reflection.foreign_key.to_s
            else
              foreign_key_reflection.primary_key_name.to_s
            end
          end
        end

        def foreign_key_reflection
          if [:has_one, :has_many].include?(macro) && reflection.options.include?(:inverse_of)
            associated_class.reflect_on_association(reflection.options[:inverse_of])
          else
            reflection
          end
        end

        def submatchers_match?
          failing_submatchers.empty?
        end
      end
    end
  end
end
