require 'test_helper'

class ContextTest < ActiveSupport::TestCase # :nodoc:

  def self.context_macro(&blk)
    context "with a subcontext made by a macro" do
      setup { @context_macro = :foo }

      merge_block &blk
    end
  end

  # def self.context_macro(&blk)
  #   context "with a subcontext made by a macro" do
  #     setup { @context_macro = :foo }
  #     yield # <- this doesn't work.
  #   end
  # end

  context "context with setup block" do
    setup do
      @blah = "blah"
    end

    should "run the setup block" do
      assert_equal "blah", @blah
    end

    should "have name set right" do
      assert_match(/^test: context with setup block/, self.to_s)
    end

    context "and a subcontext" do
      setup do
        @blah = "#{@blah} twice"
      end

      should "be named correctly" do
        assert_match(/^test: context with setup block and a subcontext should be named correctly/, self.to_s)
      end

      should "run the setup blocks in order" do
        assert_equal @blah, "blah twice"
      end
    end

    context_macro do
      should "have name set right" do
        assert_match(/^test: context with setup block with a subcontext made by a macro should have name set right/, self.to_s)
      end

      should "run the setup block of that context macro" do
        assert_equal :foo, @context_macro
      end

      should "run the setup block of the main context" do
        assert_equal "blah", @blah
      end
    end

  end

  context "another context with setup block" do
    setup do
      @blah = "foo"
    end

    should "have @blah == 'foo'" do
      assert_equal "foo", @blah
    end

    should "have name set right" do
      assert_match(/^test: another context with setup block/, self.to_s)
    end
  end

  context "context with method definition" do
    setup do
      def hello; "hi"; end
    end

    should "be able to read that method" do
      assert_equal "hi", hello
    end

    should "have name set right" do
      assert_match(/^test: context with method definition/, self.to_s)
    end
  end

  context "another context" do
    should "not define @blah" do
      assert_nil @blah
    end
  end

  context "context with multiple setups and/or teardowns" do

    cleanup_count = 0

    2.times do |i|
      setup { cleanup_count += 1 }
      teardown { cleanup_count -= 1 }
    end

    2.times do |i|
      should "call all setups and all teardowns (check ##{i + 1})" do
        assert_equal 2, cleanup_count
      end
    end

    context "subcontexts" do

      2.times do |i|
        setup { cleanup_count += 1 }
        teardown { cleanup_count -= 1 }
      end

      2.times do |i|
        should "also call all setups and all teardowns in parent and subcontext (check ##{i + 1})" do
          assert_equal 4, cleanup_count
        end
      end

    end

  end

  should_eventually "pass, since it's unimplemented" do
    flunk "what?"
  end

  should_eventually "not require a block when using should_eventually"
  should "pass without a block, as that causes it to piggyback to should_eventually"

  context "context for testing should piggybacking" do
    should "call should_eventually as we are not passing a block"
  end

  context "context" do
    context "with nested subcontexts" do
      should_eventually "only print this statement once for a should_eventually"
    end
  end

  class ::SomeModel; end

  context "given a test named after a class" do
    setup do
      self.class.stubs(:name).returns("SomeModelTest")
    end

    should "determine the described type" do
      assert_equal SomeModel, self.class.described_type
    end

    should "return a new instance of the described type as the subject if none exists" do
      assert_kind_of SomeModel, subject
    end

    context "with an explicit subject block" do
      setup { @expected = SomeModel.new }
      subject { @expected }
      should "return the result of the block as the subject" do
        assert_equal @expected, subject
      end

      context "nested context block without a subject block" do
        should "return the result of the parent context's subject block" do
          assert_equal @expected, subject
        end
      end
    end
  end
end

class ShouldMatcherTest < Test::Unit::TestCase
  class FakeMatcher
    attr_reader :subject
    attr_accessor :fail

    def description
      "do something"
    end

    def matches?(subject)
      @subject = subject
      !@fail
    end

    def failure_message
      "a failure message"
    end

    def negative_failure_message
      "not a failure message"
    end
  end

  def run_test
    @test_suite.run(@test_result) { |event, name |}
  end

  def setup
    @matcher = FakeMatcher.new
    @test_result = Test::Unit::TestResult.new
    class << @test_result
      def failure_messages
        @failures.map { |failure| failure.message }
      end
    end
  end

  def create_test_suite(&definition)
    test_class = Class.new(Test::Unit::TestCase, &definition)
    test_class.suite
  end

  def assert_failed_with(message, test_result)
    assert_equal 1, test_result.failure_count
    assert_equal [message], test_result.failure_messages
  end

  def assert_passed(test_result)
    assert_equal 0, test_result.failure_count
  end

  def assert_test_named(expected_name, test_suite)
    name = test_suite.tests.map { |test| test.method_name }.first
    assert name.include?(expected_name), "Expected #{name} to include #{expected_name}"
  end

  def self.should_use_positive_matcher
    should "generate a test using the matcher's description" do
      assert_test_named "should #{@matcher.description}", @test_suite
    end

    should "pass with a passing matcher" do
      @matcher.fail = false
      run_test
      assert_passed @test_result
    end

    should "fail with a failing matcher" do
      @matcher.fail = true
      run_test
      assert_failed_with @matcher.failure_message, @test_result
    end

    should "provide the subject" do
      @matcher.fail = false
      run_test
      assert_equal 'a subject', @matcher.subject
    end
  end

  def self.should_use_negative_matcher
    should "generate a test using the matcher's description" do
      assert_test_named "should not #{@matcher.description}", @test_suite
    end

    should "pass with a failing matcher" do
      @matcher.fail = true
      run_test
      assert_passed @test_result
    end

    should "fail with a passing matcher" do
      @matcher.fail = false
      run_test
      assert_failed_with @matcher.negative_failure_message, @test_result
    end

    should "provide the subject" do
      @matcher.fail = false
      run_test
      assert_equal 'a subject', @matcher.subject
    end
  end

  context "a should block with a matcher" do
    setup do
      matcher = @matcher
      @test_suite = create_test_suite do
        subject { 'a subject' }
        should matcher
      end
    end

    should_use_positive_matcher
  end

  context "a should block with a matcher within a context" do
    setup do
      matcher = @matcher
      @test_suite = create_test_suite do
        context "in context" do
          subject { 'a subject' }
          should matcher
        end
      end
    end

    should_use_positive_matcher
  end

  context "a should_not block with a matcher" do
    setup do
      matcher = @matcher
      @test_suite = create_test_suite do
        subject { 'a subject' }
        should_not matcher
      end
    end

    should_use_negative_matcher
  end

  context "a should_not block with a matcher within a context" do
    setup do
      matcher = @matcher
      @test_suite = create_test_suite do
        context "in context" do
          subject { 'a subject' }
          should_not matcher
        end
      end
    end

    should_use_negative_matcher
  end
end

class Subject; end

class SubjectTest < ActiveSupport::TestCase

  def setup
    @expected = Subject.new
  end

  subject { @expected }

  should "return a specified subject" do
    assert_equal @expected, subject
  end
end

class SubjectLazinessTest < ActiveSupport::TestCase
  subject { Subject.new }

  should "only build the subject once" do
    assert_equal subject, subject
  end
end

class SomeController < ActionController::Base
end

class ControllerSubjectTest < ActionController::TestCase
  tests SomeController

  should "use the controller as the subject outside a context" do
    assert_equal @controller, subject
  end

  context "in a context" do
    should "use the controller as the subject" do
      assert_equal @controller, subject
    end
  end
end
