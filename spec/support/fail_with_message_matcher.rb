RSpec::Matchers.define :fail_with_message do |expected|
  match do |block|
    @actual = nil

    begin
      block.call
    rescue RSpec::Expectations::ExpectationNotMetError => ex
      @actual = ex.message
    end

    @actual && @actual == expected
  end

  failure_message_for_should do
    msg = "Expectation should have failed with message '#{expected}'"

    if @actual
      msg << ", actually failed with '#{@actual}'"
    else
      msg << ", but did not fail."
    end

    msg
  end

  failure_message_for_should_not do
    msg  = "Expectation should not have failed with message '#{expected}'"
    msg << ", but did."

    msg
  end
end
