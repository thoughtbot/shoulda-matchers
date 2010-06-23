Feature: integrate with Rails

  Background:
    When I generate a new rails application
    And I configure the application to use "shoulda" from this project
    And I save the following as "db/migrate/1_create_users.rb"
      """
      class CreateUsers < ActiveRecord::Migration
        def self.up
          create_table :users do |t|
            t.string :name
          end
        end
      end
      """
    When I run "rake db:migrate"
    And I save the following as "app/models/user.rb"
      """
      class User < ActiveRecord::Base
        validates_presence_of :name
      end
      """
    When I save the following as "app/controllers/examples_controller.rb"
      """
      class ExamplesController < ApplicationController
        def show
          @example = 'hello'
          render :nothing => true
        end
      end
      """
    When I configure a wildcard route

  Scenario: generate a rails application and use macros in Test::Unit
    When I save the following as "test/unit/user_test.rb"
      """
      require 'test_helper'

      class UserTest < ActiveSupport::TestCase
        should_validate_presence_of :name
      end
      """
    When I save the following as "test/functional/examples_controller_test.rb"
      """
      require 'test_helper'

      class ExamplesControllerTest < ActionController::TestCase
        def setup
          get :show
        end

        should_respond_with :success
        should_assign_to :example
      end
      """
    When I run "rake test TESTOPTS=-v"
    Then I should see "1 tests, 1 assertions, 0 failures, 0 errors"
    And I should see "2 tests, 2 assertions, 0 failures, 0 errors"
    And I should see "User should require name to be set"
    And I should see "ExamplesController should assign @example"

  Scenario: generate a rails application and use matchers in Test::Unit
    When I save the following as "test/unit/user_test.rb"
      """
      require 'test_helper'

      class UserTest < ActiveSupport::TestCase
        should validate_presence_of(:name)
      end
      """
    When I save the following as "test/functional/examples_controller_test.rb"
      """
      require 'test_helper'

      class ExamplesControllerTest < ActionController::TestCase
        def setup
          get :show
        end

        should respond_with(:success)
        should assign_to(:example)
      end
      """
    When I run "rake test TESTOPTS=-v"
    Then I should see "1 tests, 1 assertions, 0 failures, 0 errors"
    And I should see "2 tests, 2 assertions, 0 failures, 0 errors"
    And I should see "User should require name to be set"
    And I should see "ExamplesController should assign @example"

  Scenario: generate a rails application and use matchers in Rspec
    When I configure the application to use rspec-rails
    And I run the rspec generator
    And I save the following as "spec/models/user_spec.rb"
      """
      require 'spec_helper'

      describe User do
        it { should validate_presence_of(:name) }
      end
      """
    When I save the following as "spec/controllers/examples_controller_spec.rb"
      """
      require 'spec_helper'

      describe ExamplesController, "show" do
        before { get :show }
        # rspec2 doesn't use the controller as the subject
        subject { controller }
        it { should assign_to(:example) }
      end
      """
    When I run "rake spec SPEC_OPTS=-fs"
    Then I should see "2 examples, 0 failures"
    And I should see "should require name to be set"
    And I should see "should assign @example"
