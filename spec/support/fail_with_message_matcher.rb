RSpec::Matchers.define :fail_with_message do |expected|
  def supports_block_expectations?
    true
  end

  match do |block|
    @actual = nil

    begin
      block.call
    rescue RSpec::Expectations::ExpectationNotMetError => ex
      @actual = ex.message
    end

    @actual && @actual == expected
  end

  def failure_message
    msg = "Expectation should have failed with message '#{expected}'"

    if @actual
      msg << ", actually failed with '#{@actual}'"
    else
      msg << ", but did not fail."
    end

    msg
  end

  def failure_message_for_should
    failure_message
  end

  def failure_message_when_negated
    msg  = "Expectation should not have failed with message '#{expected}'"
    msg << ", but did."

    msg
  end

  def failure_message_for_should_not
    failure_message_when_negated
  end
end
