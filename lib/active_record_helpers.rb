module ThoughtBot # :nodoc:
  module Shoulda # :nodoc:
    # = Macro test helpers for your active record models
    #
    # These helpers will test most of the validations and associations for your ActiveRecord models.
    #
    #   class UserTest < Test::Unit
    #     should_require_attributes :name, :phone_number
    #     should_not_allow_values_for :phone_number, "abcd", "1234"
    #     should_allow_values_for :phone_number, "(123) 456-7890"
    #     
    #     should_protect_attributes :password
    #     
    #     should_have_one :profile
    #     should_have_many :dogs
    #     should_have_many :messes, :through => :dogs
    #     should_belong_to :lover
    #   end
    #
    # For all of these helpers, the last parameter may be a hash of options.
    #
    module ActiveRecord
      # Ensures that the model cannot be saved if one of the attributes listed is not present.
      # Requires an existing record.
      #
      # Options:
      # * <tt>:message</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt>.  
      #   Regexp or string.  Default = <tt>/blank/</tt>
      #
      # Example:
      #   should_require_attributes :name, :phone_number
      def should_require_attributes(*attributes)
        opts = opts_from(attributes)
        opts[:message] ||= /blank/
        klass = model_class
        
        attributes.each do |attribute|
          should "require #{attribute} to be set" do
            object = klass.new
            assert !object.valid?, "Instance is still valid"
            assert object.errors.on(attribute), "No errors found"
            assert_contains(object.errors.on(attribute), opts[:message])
          end
        end
      end

      # Ensures that the model cannot be saved if one of the attributes listed is not unique.
      # Requires an existing record
      #
      # Options:
      # * <tt>:message</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt>.  
      #   Regexp or string.  Default = <tt>/taken/</tt>
      #
      # Example:
      #   should_require_unique_attributes :keyword, :username
      def should_require_unique_attributes(*attributes)
        opts = opts_from(attributes)
        opts[:message] ||= /taken/
        scope = opts[:scoped_to]
        
        klass = model_class
        attributes.each do |attribute|
          attribute = attribute.to_sym
          should "require unique value for #{attribute}#{" scoped to #{scope}" if scope}" do
            assert existing = klass.find(:first), "Can't find first #{klass}"
            object = klass.new
            
            object.send(:"#{attribute}=", existing.send(attribute))
            if scope
              assert_respond_to object, :"#{scope}="
              object.send(:"#{scope}=", existing.send(scope))
            end
            
            assert !object.valid?, "Instance is still valid"
            assert object.errors.on(attribute), "No errors found"
            
            assert_contains(object.errors.on(attribute), opts[:message])
            
            if scope
              # Now test that the object is valid when changing the scoped attribute
              object.send(:"#{scope}=", existing.send(scope).nil? ? 1 : existing.send(scope).next)
              object.errors.clear
              object.valid?
              assert_does_not_contain(object.errors.on(attribute), opts[:message], 
                                      "after :#{scope} set to #{object.send(scope.to_sym)}")
            end
          end
        end
      end

      # Ensures that the attribute cannot be set on update
      # Requires an existing record
      #
      #   should_protect_attributes :password, :admin_flag
      def should_protect_attributes(*attributes)
        opts = opts_from(attributes)
        klass = model_class
        attributes.each do |attribute|
          attribute = attribute.to_sym
          should "not allow #{attribute} to be changed by update" do
            assert object = klass.find(:first), "Can't find first #{klass}"
            value = object[attribute]
            assert object.update_attributes({ attribute => 1 }), 
                   "Cannot update #{klass} with { :#{attribute} => 1 }, #{object.errors.full_messages.to_sentence}"
            assert object.valid?, "#{klass} isn't valid after changing #{attribute}"
            assert_equal value, object[attribute], "Was able to change #{klass}##{attribute}"
          end
        end
      end
  
      # Ensures that the attribute cannot be set to the given values
      # Requires an existing record
      #
      # Options:
      # * <tt>:message</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt>.  
      #   Regexp or string.  Default = <tt>/invalid/</tt>
      #
      # Example:
      #   should_not_allow_values_for :isbn, "bad 1", "bad 2"
      def should_not_allow_values_for(attribute, *bad_values)
        opts = opts_from(bad_values)
        opts[:message] ||= /invalid/
        klass = model_class
        bad_values.each do |v|
          should "not allow #{attribute} to be set to \"#{v}\"" do
            assert object = klass.find(:first), "Can't find first #{klass}"
            object.send("#{attribute}=", v)
            assert !object.save, "Saved #{klass} with #{attribute} set to \"#{v}\""
            assert object.errors.on(attribute), "There are no errors set on #{attribute} after being set to \"#{v}\""
            assert_contains(object.errors.on(attribute), opts[:message], "when set to \"#{v}\"")
          end
        end
      end
  
      # Ensures that the attribute can be set to the given values.
      # Requires an existing record
      #
      # Options:
      # * <tt>:message</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt>.  
      #   Regexp or string.  Default = <tt>/invalid/</tt>
      #
      # Example:
      #   should_allow_values_for :isbn, "isbn 1 2345 6789 0", "ISBN 1-2345-6789-0"
      def should_allow_values_for(attribute, *good_values)
        opts = opts_from(good_values)
        opts[:message] ||= /invalid/
        klass = model_class
        good_values.each do |v|
          should "allow #{attribute} to be set to \"#{v}\"" do
            assert object = klass.find(:first), "Can't find first #{klass}"
            object.send("#{attribute}=", v)
            object.save
            assert_does_not_contain(object.errors.on(attribute), opts[:message], "when set to \"#{v}\"")
          end
        end
      end

      # Ensures that the length of the attribute is in the given range
      # Requires an existing record
      #
      # Options:
      # * <tt>:short_message</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt>.  
      #   Regexp or string.  Default = <tt>/short/</tt>
      # * <tt>:long_message</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt>.  
      #   Regexp or string.  Default = <tt>/long/</tt>
      #
      # Example:
      #   should_ensure_length_in_range :password, (6..20)
      def should_ensure_length_in_range(attribute, range, opts = {})
        opts[:short_message] ||= /short/
        opts[:long_message]  ||= /long/
        klass = model_class
        min_length = range.first
        max_length = range.last

        min_value = "x" * (min_length - 1)
        max_value = "x" * (max_length + 1)

        should "not allow #{attribute} to be less than #{min_length} chars long" do
          assert object = klass.find(:first), "Can't find first #{klass}"
          object.send("#{attribute}=", min_value)
          assert !object.save, "Saved #{klass} with #{attribute} set to \"#{min_value}\""
          assert object.errors.on(attribute), "There are no errors set on #{attribute} after being set to \"#{min_value}\""
          assert_contains(object.errors.on(attribute), opts[:short_message], "when set to \"#{min_value}\"")
        end
    
        should "not allow #{attribute} to be more than #{max_length} chars long" do
          assert object = klass.find(:first), "Can't find first #{klass}"
          object.send("#{attribute}=", max_value)
          assert !object.save, "Saved #{klass} with #{attribute} set to \"#{max_value}\""
          assert object.errors.on(attribute), "There are no errors set on #{attribute} after being set to \"#{max_value}\""
          assert_contains(object.errors.on(attribute), opts[:long_message], "when set to \"#{max_value}\"")
        end
      end    

      # Ensure that the attribute is in the range specified
      # Requires an existing record
      #
      # Options:
      # * <tt>:low_message</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt>.  
      #   Regexp or string.  Default = <tt>/included/</tt>
      # * <tt>:high_message</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt>.  
      #   Regexp or string.  Default = <tt>/included/</tt>
      #
      # Example:
      #   should_ensure_value_in_range :age, (0..100)
      def should_ensure_value_in_range(attribute, range, opts = {})
        opts[:low_message]  ||= /included/
        opts[:high_message] ||= /included/
        klass = model_class
        min = range.first
        max = range.last

        should "not allow #{attribute} to be less than #{min}" do
          v = min - 1
          assert object = klass.find(:first), "Can't find first #{klass}"
          object.send("#{attribute}=", v)
          assert !object.save, "Saved #{klass} with #{attribute} set to \"#{v}\""
          assert object.errors.on(attribute), "There are no errors set on #{attribute} after being set to \"#{v}\""
          assert_contains(object.errors.on(attribute), opts[:low_message], "when set to \"#{v}\"")
        end
    
        should "not allow #{attribute} to be more than #{max}" do
          v = max + 1
          assert object = klass.find(:first), "Can't find first #{klass}"
          object.send("#{attribute}=", v)
          assert !object.save, "Saved #{klass} with #{attribute} set to \"#{v}\""
          assert object.errors.on(attribute), "There are no errors set on #{attribute} after being set to \"#{v}\""
          assert_contains(object.errors.on(attribute), opts[:high_message], "when set to \"#{v}\"")
        end
      end    
      
      # Ensure that the attribute is numeric
      # Requires an existing record
      #
      # Options:
      # * <tt>:message</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt>.  
      #   Regexp or string.  Default = <tt>/number/</tt>
      #
      # Example:
      #   should_only_allow_numeric_values_for :age
      def should_only_allow_numeric_values_for(*attributes)
        opts = opts_from(attributes)
        opts[:message]  ||= /number/
        klass = model_class
        attributes.each do |attribute|
          attribute = attribute.to_sym
          should "only allow numeric values for #{attribute}" do
            assert object = klass.find(:first), "Can't find first #{klass}"
            object.send(:"#{attribute}=", "abcd")
            assert !object.valid?, "Instance is still valid"
            assert_contains(object.errors.on(attribute), opts[:message])
          end
        end
      end

      # Ensures that the has_many relationship exists.
      # 
      # Options:
      # * <tt>:through</tt> - association name for <tt>has_many :through</tt>
      #
      # Example:
      #   should_have_many :friends
      #   should_have_many :enemies, :through => :friends
      def should_have_many(*associations)
        opts = opts_from(associations)
        klass = model_class
        associations.each do |association|
          should "have many #{association}#{" through #{opts[:through]}" if opts[:through]}" do
            reflection = klass.reflect_on_association(association)
            assert reflection
            assert_equal :has_many, reflection.macro
            assert_equal(opts[:through], reflection.options[:through]) if opts[:through]
          end
        end
      end

      # Ensures that the has_and_belongs_to_many relationship exists.  
      #
      #   should_have_and_belong_to_many :posts, :cars
      def should_have_and_belong_to_many(*associations)
        opts = opts_from(associations)
        klass = model_class
        associations.each do |association|
          should "should have and belong to many #{association}" do
            assert klass.reflect_on_association(association)
            assert_equal :has_and_belongs_to_many, klass.reflect_on_association(association).macro
          end
        end
      end
  
      # Ensure that the has_one relationship exists.
      #
      #   should_have_one :god # unless hindu
      def should_have_one(*associations)
        opts = opts_from(associations)
        klass = model_class
        associations.each do |association|
          should "have one #{association}" do
            assert klass.reflect_on_association(association)
            assert_equal :has_one, klass.reflect_on_association(association).macro
          end
        end
      end
  
      # Ensure that the belongs_to relationship exists.
      #
      #   should_belong_to :parent
      def should_belong_to(*associations)
        opts = opts_from(associations)
        klass = model_class
        associations.each do |association|
          should "belong_to #{association}" do
            assert klass.reflect_on_association(association)
            assert_equal :belongs_to, klass.reflect_on_association(association).macro
          end
        end
      end
      
      private
      
      def opts_from(collection)
        collection.last.is_a?(Hash) ? collection.pop : {}
      end

      def model_class
        self.name.gsub(/Test$/, '').constantize
      end
              
    end
  end
end