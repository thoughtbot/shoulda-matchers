require 'shoulda/context'
require 'shoulda/private_helpers'
require 'shoulda/general'
require 'shoulda/active_record_helpers'
require 'shoulda/controller_tests/controller_tests.rb'
require 'yaml'

shoulda_options = {}

possible_config_paths = []
possible_config_paths << File.join(ENV["HOME"], ".shoulda.conf")       if ENV["HOME"]
possible_config_paths << "shoulda.conf"
possible_config_paths << File.join("test", "shoulda.conf")
possible_config_paths << File.join(RAILS_ROOT, "test", "shoulda.conf") if defined?(RAILS_ROOT) 

possible_config_paths.each do |config_file|
  if File.exists? config_file
    shoulda_options = YAML.load_file(config_file).symbolize_keys
    break
  end
end

require 'shoulda/color' if shoulda_options[:color]

module Shoulda
  class << self
    attr_accessor :current_context
  end

  VERSION = '1.1.1'

  # = Should statements
  #
  # Should statements are just syntactic sugar over normal Test::Unit test methods.  A should block 
  # contains all the normal code and assertions you're used to seeing, with the added benefit that 
  # they can be wrapped inside context blocks (see below).
  #
  # == Example:
  #
  #  class UserTest << Test::Unit::TestCase
  #    
  #    def setup
  #      @user = User.new("John", "Doe")
  #    end
  #
  #    should "return its full name"
  #      assert_equal 'John Doe', @user.full_name
  #    end
  #  
  #  end
  #   
  # ...will produce the following test:
  # * <tt>"test: User should return its full name. "</tt>
  #
  # Note: The part before <tt>should</tt> in the test name is gleamed from the name of the Test::Unit class.

  def should(name, &blk)
    should_eventually(name) && return unless block_given?
    
    if Shoulda.current_context
      Shoulda.current_context.should(name, &blk)
    else
      context_name = self.name.gsub(/Test/, "")
      context = Shoulda::Context.new(context_name, self) do
        should(name, &blk)
      end
      context.build
    end
  end

  # Just like should, but never runs, and instead prints an 'X' in the Test::Unit output.
  def should_eventually(name, &blk)
    context_name = self.name.gsub(/Test/, "")
    context = Shoulda::Context.new(context_name, self) do
      should_eventually(name, &blk)
    end
    context.build
  end

  # = Contexts
  # 
  # A context block groups should statements under a common set of setup/teardown methods.  
  # Context blocks can be arbitrarily nested, and can do wonders for improving the maintainability
  # and readability of your test code.
  #
  # A context block can contain setup, should, should_eventually, and teardown blocks.
  #
  #  class UserTest << Test::Unit::TestCase
  #    context "A User instance" do
  #      setup do
  #        @user = User.find(:first)
  #      end
  #    
  #      should "return its full name"
  #        assert_equal 'John Doe', @user.full_name
  #      end
  #    end
  #  end
  #
  # This code will produce the method <tt>"test: A User instance should return its full name. "</tt>.
  #
  # Contexts may be nested.  Nested contexts run their setup blocks from out to in before each 
  # should statement.  They then run their teardown blocks from in to out after each should statement.
  #
  #  class UserTest << Test::Unit::TestCase
  #    context "A User instance" do
  #      setup do
  #        @user = User.find(:first)
  #      end
  #    
  #      should "return its full name"
  #        assert_equal 'John Doe', @user.full_name
  #      end
  #    
  #      context "with a profile" do
  #        setup do
  #          @user.profile = Profile.find(:first)
  #        end
  #      
  #        should "return true when sent :has_profile?"
  #          assert @user.has_profile?
  #        end
  #      end
  #    end
  #  end
  #
  # This code will produce the following methods 
  # * <tt>"test: A User instance should return its full name. "</tt>
  # * <tt>"test: A User instance with a profile should return true when sent :has_profile?. "</tt>
  #
  # <b>Just like should statements, a context block can exist next to normal <tt>def test_the_old_way; end</tt> 
  # tests</b>.  This means you do not have to fully commit to the context/should syntax in a test file.

  def context(name, &blk)
    if Shoulda.current_context
      Shoulda.current_context.context(name, &blk)
    else
      context = Shoulda::Context.new(name, self, &blk)
      context.build
    end
  end
end

module Test # :nodoc: all
  module Unit 
    class TestCase

      include Shoulda::General
      include Shoulda::Controller

      extend Shoulda::ActiveRecord
    end
  end
end

module ActionController #:nodoc: all
  module Integration
    class Session 
      include Shoulda::General
    end
  end
end
