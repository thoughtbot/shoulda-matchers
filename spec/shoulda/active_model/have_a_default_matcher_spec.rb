require 'spec_helper'

describe Shoulda::Matchers::ActiveModel::HaveADefaultMatcher do

  context "an attribute with a default value" do
    before do
      define_model :example, :attr => :string do
        before_validation :set_attr
        def set_attr
          self.attr = "abc" if attr.nil?
        end
      end
      @model = Example.new
    end

    subject {@model}

    describe "when testing with the right default value" do
      it {should have_a_default.of("abc").for(:attr) }
      it {should have_a_default.of("abc").for(:attr).column }
      it {should have_a_default.of("abc").for(:attr).attribute}
      it {should default_to("abc").on_the(:attr) }
      it {should default_to("abc").on_the(:attr).column }
      it {should default_to("abc").on_the(:attr).attribute }
    end

    describe "when testing for any default value" do
      it {should have_a_default.for(:attr) }
      it {should have_a_default.for(:attr).column }
      it {should have_a_default.for(:attr).attribute}
    end

    describe "when testing with the wrong default value" do
      it {should_not have_a_default.of("xyz").for(:attr) }
      it {should_not have_a_default.of("xyz").for(:attr).column }
      it {should_not have_a_default.of("xyz").for(:attr).attribute}
      it {should_not default_to("xyz").on_the(:attr) }
      it {should_not default_to("xyz").on_the(:attr).column }
      it {should_not default_to("xyz").on_the(:attr).attribute }
    end
  end

  context "an attribute without a default value" do
    before do
      define_model :example, :attr => :string
      @model = Example.new
    end

    subject {@model}

    describe "when testing for any default value" do
      it {should_not have_a_default.for(:attr) }
      it {should_not have_a_default.for(:attr).column }
      it {should_not have_a_default.for(:attr).attribute}
    end

    describe "when testing with the wrong default value" do
      it {should_not have_a_default.of("xyz").for(:attr) }
      it {should_not have_a_default.of("xyz").for(:attr).column }
      it {should_not have_a_default.of("xyz").for(:attr).attribute}
      it {should_not default_to("xyz").on_the(:attr) }
      it {should_not default_to("xyz").on_the(:attr).column }
      it {should_not default_to("xyz").on_the(:attr).attribute }
    end
  end
end
