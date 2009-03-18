require File.join(File.dirname(__FILE__), '..', 'test_helper')

class AutoloadMacroTest < ActiveSupport::TestCase # :nodoc:
  context "The macro auto-loader" do
    should "load macros from the plugins" do
      assert self.class.respond_to?('plugin_macro')
    end

    should "load macros from the gems" do
      assert self.class.respond_to?('gem_macro')
    end

    should "load custom macros from ROOT/test/shoulda_macros" do
      assert self.class.respond_to?('custom_macro')
    end
  end
end

