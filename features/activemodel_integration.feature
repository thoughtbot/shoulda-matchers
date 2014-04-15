Feature: integration with ActiveModel

  Scenario: create a new project using matchers
    When I generate a new ActiveModel application
    And I configure the application to use "shoulda-matchers" from this project
    And I write to "load_dependencies.rb" with:
      """
      require 'active_model'
      require 'shoulda-matchers'

      puts ActiveModel::VERSION::STRING
      puts "Loaded all dependencies without errors"
      """
    When I successfully run `bundle exec ruby load_dependencies.rb`
    Then the output should contain "Loaded all dependencies without errors"
