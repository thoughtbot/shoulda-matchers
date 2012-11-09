# encoding: UTF-8

require 'spec_helper'

describe Shoulda::Matchers::ActiveModel::ValidateFormatOfMatcher do

  context "a country" do
    let(:model) do
      define_model :example, :attr => :string do
        validates_format_of :attr, :with => /\A[\p{Lu}\p{Ll} ]+\z/
      end.new
    end

    subject { model }

    it "raise an error when allowing or denying is not used" do
      lambda { should validate_format_of(:attr) }.should raise_error "Matcher needs a example value, use #allowing or #denying methods to fix it."
    end

    it "raise an error when allowing and denying is used at same time" do
      lambda { validate_format_of(:attr).allowing("").denying("") }.should raise_error "You may not call both #allowing and #denying"
    end

    it "is not valid with blank country name" do
      should_not validate_format_of(:attr).allowing("")
      should validate_format_of(:attr).denying("")
    end

    it "is not valid with nil country name" do
      should_not validate_format_of(:attr).allowing(nil)
      should validate_format_of(:attr).denying(nil)
    end

    it "is valid with ASCII letter in country name" do
      should validate_format_of(:attr).allowing("Brazil")
      should_not validate_format_of(:attr).denying("Brazil")
    end

    it "is not valid with a non ASCII character in country name" do
      should_not validate_format_of(:attr).allowing("Bra$il")
      should validate_format_of(:attr).denying("Bra$il")
    end

    it "is valid with an Unicode letter in country name" do
      should validate_format_of(:attr).allowing("Canadá")
      should_not validate_format_of(:attr).denying("Canadá")
    end

    it "is not valid with a non Unicode character in country name" do
      should_not validate_format_of(:attr).allowing("Can@dá")
      should validate_format_of(:attr).denying("Can@dá")
    end

    it "is not valid with a numeric character in country name" do
      should validate_format_of(:attr).denying("Japan 3")
      should_not validate_format_of(:attr).allowing("Japan 3")
    end

    it "is valid with any uppercase, lowercase or spaces in country name" do
      should validate_format_of(:attr).allowing("Mexico").placing(/[\p{Lu}\p{Ll} ]/u)
      should_not validate_format_of(:attr).denying("Mexico").placing(/[\p{Lu}\p{Ll} ]/u)
    end

    it "is not valid with any uppercase, lowercase or spaces in country name" do
      should_not validate_format_of(:attr).allowing("Mexico").placing(/[^\p{Lu}\p{Ll} ]/u)
      should validate_format_of(:attr).denying("Mexico").placing(/[^\p{Lu}\p{Ll} ]/u)
    end
  end

  context "a capitalized country" do
    let(:model) do
      define_model :example, :attr => :string do
        validates_format_of :attr, :with => /\A[\p{Lu}]{1}[\p{Ll} ]+\z/
      end.new
    end

    subject { model }

    it "is valid with any uppercased letter as first character" do
      should validate_format_of(:attr).allowing("United states").placing(/[\p{Lu}]/u).at(0)
      should_not validate_format_of(:attr).denying("United states").placing(/[\p{Lu}]/u).at(0)
    end

    it "is not valid with any non uppercased letter as first character" do
      should_not validate_format_of(:attr).allowing("United states").placing(/[^\p{Lu}]/u).at(0)
      should validate_format_of(:attr).denying("United states").placing(/[^\p{Lu}]/u).at(0)
    end

    it "is valid with any lowercased letter or space after first character" do
      should validate_format_of(:attr).allowing("United states").placing(/[\p{Ll} ]/u).at(1..12)
      should_not validate_format_of(:attr).denying("United states").placing(/[\p{Ll} ]/u).at(1..12)
    end

    it "is not valid with any non lowercased letter or space after first character" do
      should_not validate_format_of(:attr).allowing("United states").placing(/[^\p{Ll} ]/u).at(1..12)
      should validate_format_of(:attr).denying("United states").placing(/[^\p{Ll} ]/u).at(1..12)
    end
  end

  context "a phone" do
    let(:model) do
      define_model :example, :attr => :string do
        validates_format_of :attr, :with => /\A\+\d{2}\p{Z}\(\d{2}\)\p{Z}\d{4}\p{P}\d{4}\z/u
      end.new
    end

    subject { model }

    it "is valid when starting with '+'" do
      should validate_format_of(:attr).allowing("+00 (11) 2222-3333").placing("+").at(0)
      should_not validate_format_of(:attr).denying("+00 (11) 2222-3333").placing("+").at(0)
    end

    it "is not valid when not starting with '+'" do
      should_not validate_format_of(:attr).allowing("+00 (11) 2222-3333").placing(%W"- . * x").at(0)
      should validate_format_of(:attr).denying("+00 (11) 2222-3333").placing(%W"- . * x").at(0)
    end

    it "is valid when using numeric digits in expected places" do
      should validate_format_of(:attr).allowing("+00 (11) 2222-3333").placing(/[\p{Nd}]/u).at(1..2, 5..6, 9..12, 14..17)
      should_not validate_format_of(:attr).denying("+00 (11) 2222-3333").placing(/[\p{Nd}]/u).at(1..2, 5..6, 9..12, 14..17)
    end

    it "is not valid when not using numeric digits in expected places" do
      should_not validate_format_of(:attr).allowing("+00 (11) 2222-3333").placing(/[\p{^Nd}]/u).at(1..2, 5..6, 9..12, 14..17)
      should validate_format_of(:attr).denying("+00 (11) 2222-3333").placing(/[\p{^Nd}]/u).at(1..2, 5..6, 9..12, 14..17)
    end

    it "is valid when using separators between number sets" do
      should validate_format_of(:attr).allowing("+00 (11) 2222-3333").placing(/[\p{Z}]/u).at(3, 8)
      should_not validate_format_of(:attr).denying("+00 (11) 2222-3333").placing(/[\p{Z}]/u).at(3, 8)
    end

    it "is not valid when using non separators between number sets" do
      should_not validate_format_of(:attr).allowing("+00 (11) 2222-3333").placing(/[\p{^Z}]/u).at(3, 8)
      should validate_format_of(:attr).denying("+00 (11) 2222-3333").placing(/[\p{^Z}]/u).at(3, 8)
    end

    it "is valid when parentesis surrounds area code" do
      should validate_format_of(:attr).allowing("+00 (11) 2222-3333").placing("(").at(4)
      should validate_format_of(:attr).allowing("+00 (11) 2222-3333").placing(")").at(7)
      should_not validate_format_of(:attr).denying("+00 (11) 2222-3333").placing("(").at(4)
      should_not validate_format_of(:attr).denying("+00 (11) 2222-3333").placing(")").at(7)
    end

    it "is not valid when a non parentesis surrounds area code" do
      should_not validate_format_of(:attr).allowing("+00 (11) 2222-3333").placing("[", "{").at(4)
      should_not validate_format_of(:attr).allowing("+00 (11) 2222-3333").placing("]", "}").at(7)
      should validate_format_of(:attr).denying("+00 (11) 2222-3333").placing("[", "{").at(4)
      should validate_format_of(:attr).denying("+00 (11) 2222-3333").placing("]", "}").at(7)
    end
  end

  context "when allow_blank and allow_nil are set" do
    let(:model) do
      define_model :example, :attr => :string do
        validates_format_of :attr, :with => /^\d{5}$/, :allow_blank => true, :allow_nil => true
      end.new
    end

    subject { model }

    it "is valid when attr is nil" do
      should validate_format_of(:attr).allowing(nil)
      should_not validate_format_of(:attr).denying(nil)
    end

    it "is valid when attr is blank" do
      should validate_format_of(:attr).allowing(' ')
      should_not validate_format_of(:attr).denying(' ')
    end

    describe "#allow_blank" do
      it "allows allow_blank" do
        should validate_format_of(:attr).allow_blank
        should validate_format_of(:attr).allow_blank(true)
        should_not validate_format_of(:attr).allow_blank(false)
      end
    end

    describe "#allow_nil" do
      it "allows allow_nil" do
        should validate_format_of(:attr).allow_nil
        should validate_format_of(:attr).allow_nil(true)
        should_not validate_format_of(:attr).allow_nil(false)
      end
    end
  end
end