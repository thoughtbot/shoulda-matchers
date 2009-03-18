require File.join(File.dirname(__FILE__), '..', '..', 'test_helper')

class ValidateAcceptanceOfMatcherTest < ActiveSupport::TestCase # :nodoc:

  context "an attribute which must be accepted" do
    setup do
      @model = define_model(:example) do
        validates_acceptance_of :attr
      end.new
    end

    should "require that attribute to be accepted" do
      assert_accepts validate_acceptance_of(:attr), @model
    end

    should "not overwrite the default message with nil" do
      assert_accepts validate_acceptance_of(:attr).with_message(nil), @model
    end
  end

  context "an attribute that does not need to be accepted" do
    setup do
      @model = define_model(:example, :attr => :string).new
    end

    should "not require that attribute to be accepted" do
      assert_rejects validate_acceptance_of(:attr), @model
    end
  end

  context "an attribute which must be accepted with a custom message" do
    setup do
      @model = define_model(:example) do
        validates_acceptance_of :attr, :message => 'custom'
      end.new
    end

    should "require that attribute to be accepted with that message" do
      assert_accepts validate_acceptance_of(:attr).with_message(/custom/),
                     @model
    end
  end

end
