module Shoulda # :nodoc:
  module ActiveRecord # :nodoc:
    module Assertions
      # Asserts that the given object can be saved
      #
      #  assert_save User.new(params)
      def assert_save(obj)
        assert obj.save, "Errors: #{pretty_error_messages obj}"
        obj.reload
      end

      # Asserts that the given object is valid
      #
      #  assert_valid User.new(params)
      def assert_valid(obj)
        assert obj.valid?, "Errors: #{pretty_error_messages obj}"
      end

      # Asserts that an Active Record model validates with the passed
      # <tt>value</tt> by making sure the <tt>error_message_to_avoid</tt> is not
      # contained within the list of errors for that attribute.
      #
      #   assert_good_value(User.new, :email, "user@example.com")
      #   assert_good_value(User.new, :ssn, "123456789", /length/)
      #
      # If a class is passed as the first argument, a new object will be
      # instantiated before the assertion.  If an instance variable exists with
      # the same name as the class (underscored), that object will be used
      # instead.
      #
      #   assert_good_value(User, :email, "user@example.com")
      #
      #   product = Product.new(:tangible => false)
      #   assert_good_value(product, :price, "0")
      def assert_good_value(object_or_klass, attribute, value, error_message_to_avoid = nil)
        object = get_instance_of(object_or_klass)
        matcher = allow_value(value).
                    for(attribute).
                    with_message(error_message_to_avoid)
        assert_accepts(matcher, object)
      end

      # Asserts that an Active Record model invalidates the passed
      # <tt>value</tt> by making sure the <tt>error_message_to_expect</tt> is
      # contained within the list of errors for that attribute.
      #
      #   assert_bad_value(User.new, :email, "invalid")
      #   assert_bad_value(User.new, :ssn, "123", /length/)
      #
      # If a class is passed as the first argument, a new object will be
      # instantiated before the assertion.  If an instance variable exists with
      # the same name as the class (underscored), that object will be used
      # instead.
      #
      #   assert_bad_value(User, :email, "invalid")
      #
      #   product = Product.new(:tangible => true)
      #   assert_bad_value(product, :price, "0")
      def assert_bad_value(object_or_klass, attribute, value,
                           error_message_to_expect = nil)
        object = get_instance_of(object_or_klass)
        matcher = allow_value(value).
                    for(attribute).
                    with_message(error_message_to_expect)
        assert_rejects(matcher, object)
      end
    end
  end
end
