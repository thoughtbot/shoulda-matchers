module Shoulda
  module Matchers
    if defined?(ActiveSupport::TestCase)
      # @private
      AssertionError = ActiveSupport::TestCase::Assertion
    elsif Gem.ruby_version >= Gem::Version.new('1.8') && Gem.ruby_version < Gem::Version.new('1.9')
      require 'test/unit'
      # @private
      AssertionError = Test::Unit::AssertionFailedError
    elsif defined?(Test::Unit::AssertionFailedError)
      # Test::Unit has been loaded already, so we use it
      # @private
      AssertionError = Test::Unit::AssertionFailedError
    elsif Gem.ruby_version >= Gem::Version.new("1.9")
      begin
        require 'minitest'
      rescue LoadError
        require 'minitest/unit'
      ensure
      # @private
        AssertionError = MiniTest::Assertion
      end
    else
      raise 'No unit test library available'
    end
  end
end
