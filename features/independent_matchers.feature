Feature: Independent matchers
  Background:
    When I generate a new Ruby application

  Scenario: A Ruby application that uses Minitest and the delegate_method matcher
    When I add Minitest to the project
    And I write to "lib/post_office.rb" with:
      """
      class PostOffice
      end
      """
    And I write to "lib/courier.rb" with:
      """
      require "forwardable"

      class Courier
        extend Forwardable

        def_delegators :post_office, :deliver

        attr_reader :post_office

        def initialize(post_office)
          @post_office = post_office
        end
      end
      """
    And I write a Minitest test to "test/courier_test.rb" with:
      """
      require "test_helper"
      require "courier"
      require "post_office"

      class CourierTest < {{MINITEST_TEST_CASE_CLASS}}
        subject { Courier.new(post_office) }

        should delegate_method(:deliver).to(:post_office)

        def post_office
          PostOffice.new
        end
      end
      """
    And I set the "TESTOPTS" environment variable to "-v"
    And I successfully run `bundle exec ruby -I lib -I test test/courier_test.rb`
    Then the output should indicate that 1 test was run
    And the output should contain "Courier should delegate #deliver to #post_office object"
