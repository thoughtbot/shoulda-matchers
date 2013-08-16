Feature: Integration with ActiveModel
  Background:
    When I generate a new Bundler project
    And I configure the project to use "activemodel" required via "active_model"
    And I configure the project to use the shoulda-matchers from the root directory

  Scenario: Using RSpec
    When I configure the project to use RSpec
    And I write to "lib/my_class.rb" with:
      """
      class MyClass
        include ActiveModel::Validations
        attr_accessor :name
        validates :name, presence: true
      end
      """
    And I write to "spec/my_class_spec.rb" with:
      """
      require 'spec_helper'
      require 'my_class'

      describe MyClass do
        it { should validate_presence_of :name }
      end
      """
    When I successfully run `bundle exec rake spec --trace`
    Then the output should contain "1 example, 0 failures"
