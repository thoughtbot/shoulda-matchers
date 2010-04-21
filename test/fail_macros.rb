module Shoulda
  class << self
    attr_accessor :expected_exceptions
  end

  module ClassMethods
    # Enables the core shoulda test suite to test for failure scenarios.  For
    # example, to ensure that a set of test macros should fail, do this:
    #
    #   should_fail do
    #     should_validate_presence_of :comments
    #     should_not_allow_mass_assignment_of :name
    #   end
    def should_fail(&block)
      context "should fail when trying to run:" do
        if defined?(Test::Unit::AssertionFailedError)
          failures = [Test::Unit::AssertionFailedError]
        elsif defined?(MiniTest::Assertion)
          failures = [MiniTest::Assertion]
        end
        Shoulda.expected_exceptions = failures
        yield block
        Shoulda.expected_exceptions = nil
      end
    end
  end

  class Context
    # alias_method_chain hack to allow the should_fail macro to work
    def should_with_failure_scenario(*args, &block)
      should_without_failure_scenario(*args, &block)
      wrap_last_should_with_failure_expectation
    end
    alias_method_chain :should, :failure_scenario

    # alias_method_chain hack to allow the should_fail macro to work
    def should_not_with_failure_scenario(*args, &block)
      should_not_without_failure_scenario(*args, &block)
      wrap_last_should_with_failure_expectation
    end
    alias_method_chain :should_not, :failure_scenario

    def wrap_last_should_with_failure_expectation
      if Shoulda.expected_exceptions
        expected_exceptions = Shoulda.expected_exceptions
        should = self.shoulds.last
        assertion_block = should[:block]
        failure_block = lambda do
          assert_raise(*expected_exceptions, &assertion_block.bind(self))
        end
        should[:block] = failure_block
      end
    end
  end
end
