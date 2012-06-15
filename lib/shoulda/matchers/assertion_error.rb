module Shoulda
  module Matchers
    if defined?(Test::Unit::AssertionFailedError)
      AssertionError = Test::Unit::AssertionFailedError
    elsif Gem.ruby_version >= Gem::Version.new("1.9")
      require 'minitest/unit'
      AssertionError = MiniTest::Assertion
    else
      raise "No unit test library available"
    end
  end
end