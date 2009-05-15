require File.join(File.dirname(__FILE__), '..', '..', 'test_helper')

class ValidateFormatOfMatcherTest < ActiveSupport::TestCase # :nodoc:


  context "a postal code" do
    setup do
      define_model :example, :attr => :string do
        validates_format_of :attr, :with => /^\d{5}$/
      end
      @model = Example.new
    end
    
    should "be valid" do
      assert_accepts validate_format_of(:attr).with('12345'), @model
    end
    
    should "not be valid with alpha in zip" do
      assert_rejects validate_format_of(:attr).not_with('1234a'), @model, :message=>"is invalid"
    end
    
    should "not be valid with to few digits" do
      assert_rejects validate_format_of(:attr).not_with('1234'), @model, :message=>"is invalid"
    end
    
    should "not be valid with to many digits" do
      assert_rejects validate_format_of(:attr).not_with('123456'), @model, :message=>"is invalid"
    end
    
    should "raise error if you try to call both with and not_with" do
      assert_raise RuntimeError do
        validate_format_of(:attr).not_with('123456').with('12345')
      end
    end
    
  end


end
