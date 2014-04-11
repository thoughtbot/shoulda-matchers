Feature: integrate with Rails

  Background:
    When I generate a new rails application
    And I write to "db/migrate/1_create_users.rb" with:
      """
      class CreateUsers < ActiveRecord::Migration
        def self.up
          create_table :users do |t|
            t.string :name
          end
        end
      end
      """
    When I successfully run `bundle exec rake db:migrate db:test:prepare --trace`
    And I write to "app/models/user.rb" with:
      """
      class User < ActiveRecord::Base
        validates_presence_of :name
      end
      """
    When I write to "app/controllers/examples_controller.rb" with:
      """
      class ExamplesController < ApplicationController
        def show
          @example = 'hello'
          render :nothing => true
        end
      end
      """
    When I configure a wildcard route

  Scenario: generate a rails application and use matchers in Test::Unit
    When I configure the application to use shoulda-context
    And I configure the application to use "shoulda-matchers" from this project
    And I write to "test/unit/user_test.rb" with:
      """
      require 'test_helper'

      class UserTest < ActiveSupport::TestCase
        should validate_presence_of(:name)
      end
      """
    When I write to "test/functional/examples_controller_test.rb" with:
      """
      require 'test_helper'

      class ExamplesControllerTest < ActionController::TestCase
        def setup
          get :show
        end

        should respond_with(:success)
      end
      """
    When I set the "TESTOPTS" environment variable to "-v"
    When I successfully run `bundle exec rake test --trace`
    Then the output should indicate that 1 unit and 1 functional test were run
    And the output should contain "User should require name to be set"
    And the output should contain "should respond with 200"

  Scenario: generate a rails application and use matchers in Rspec
    When I configure the application to use rspec-rails
    And I configure the application to use "shoulda-matchers" from this project
    And I run the rspec generator
    And I write to "spec/models/user_spec.rb" with:
      """
      require 'spec_helper'

      describe User do
        it { should validate_presence_of(:name) }
      end
      """
    When I write to "spec/controllers/examples_controller_spec.rb" with:
      """
      require 'spec_helper'

      describe ExamplesController, "show" do
        before { get :show }
        it { should respond_with(:success) }
      end
      """
    When I successfully run `bundle exec rake spec SPEC_OPTS=-fs --trace`
    Then the output should contain "2 examples, 0 failures"
    And the output should contain "should require name to be set"
    And the output should contain "should respond with 200"

  Scenario: generate a Rails application that mixes Rspec and Test::Unit
    When I configure the application to use rspec-rails in test and development
    And I configure the application to use "shoulda-matchers" from this project in test and development
    And I run the rspec generator
    And I write to "spec/models/user_spec.rb" with:
      """
      require 'spec_helper'

      describe User do
        it { should validate_presence_of(:name) }
      end
      """
    When I write to "test/functional/examples_controller_test.rb" with:
      """
      require 'test_helper'

      class ExamplesControllerTest < ActionController::TestCase
        test 'responds successfully' do
          get :show
          assert respond_with(:success)
        end
      end
      """
    When I successfully run `bundle exec rake spec test:functionals SPEC_OPTS=-fs --trace`
    Then the output should contain "1 example, 0 failures"
    Then the output should indicate that 1 test was run
