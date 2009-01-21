module Shoulda # :nodoc:
  module ActiveRecord # :nodoc:
    # = Macro test helpers for your active record models
    #
    # These helpers will test most of the validations and associations for your ActiveRecord models.
    #
    #   class UserTest < Test::Unit::TestCase
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
    module Macros
      include Helpers
      include Matchers

      # <b>DEPRECATED:</b> Use <tt>fixtures :all</tt> instead
      #
      # Loads all fixture files (<tt>test/fixtures/*.yml</tt>)
      def load_all_fixtures
        warn "[DEPRECATION] load_all_fixtures is deprecated.  Use `fixtures :all` instead."
        fixtures :all
      end

      # Ensures that the model cannot be saved if one of the attributes listed is not present.
      #
      # If an instance variable has been created in the setup named after the
      # model being tested, then this method will use that.  Otherwise, it will
      # create a new instance to test against.
      #
      # Options:
      # * <tt>:message</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt>.
      #   Regexp or string.  Default = <tt>I18n.translate('activerecord.errors.messages.blank')</tt>
      #
      # Example:
      #   should_require_attributes :name, :phone_number
      #
      def should_require_attributes(*attributes)
        message = get_options!(attributes, :message)
        klass = model_class

        attributes.each do |attribute|
          matcher = require_attribute(attribute).with_message(message)
          should matcher.description do
            assert_accepts(matcher, get_instance_of(klass))
          end
        end
      end

      # Ensures that the model cannot be saved if one of the attributes listed is not unique.
      # Requires an existing record
      #
      # Options:

      # * <tt>:message</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt>.
      #   Regexp or string.  Default = <tt>I18n.translate('activerecord.errors.messages.taken')</tt>
      # * <tt>:scoped_to</tt> - field(s) to scope the uniqueness to.
      # * <tt>:case_sensitive</tt> - whether or not uniqueness is defined by an
      #   exact match. Ignored by non-text attributes. Default = <tt>true</tt>
      #
      # Examples:
      #   should_require_unique_attributes :keyword, :username
      #   should_require_unique_attributes :name, :message => "O NOES! SOMEONE STOELED YER NAME!"
      #   should_require_unique_attributes :email, :scoped_to => :name
      #   should_require_unique_attributes :address, :scoped_to => [:first_name, :last_name]
      #   should_require_unique_attributes :email, :case_sensitive => false
      #
      def should_require_unique_attributes(*attributes)
        message, scope, case_sensitive = get_options!(attributes, :message, :scoped_to, :case_sensitive)
        scope = [*scope].compact
        case_sensitive = true if case_sensitive.nil?

        klass = model_class

        attributes.each do |attribute|
          matcher = require_unique_attribute(attribute).
            with_message(message).scoped_to(scope)
          matcher = matcher.case_insensitive unless case_sensitive
          should matcher.description do
            assert_accepts(matcher, get_instance_of(klass))
          end
        end
      end

      # Ensures that the attribute cannot be set on mass update.
      #
      #   should_protect_attributes :password, :admin_flag
      #
      def should_protect_attributes(*attributes)
        get_options!(attributes)
        klass = model_class

        attributes.each do |attribute|
          attribute = attribute.to_sym
          should "protect #{attribute} from mass updates" do
            protected = klass.protected_attributes || []
            accessible = klass.accessible_attributes || []

            assert protected.include?(attribute.to_s) ||
              (!accessible.empty? && !accessible.include?(attribute.to_s)),
                   (accessible.empty? ?
                     "#{klass} is protecting #{protected.to_a.to_sentence}, but not #{attribute}." :
                     "#{klass} has made #{attribute} accessible")
          end
        end
      end

      # Ensures that the attribute cannot be changed once the record has been created.
      #
      #   should_have_readonly_attributes :password, :admin_flag
      #
      def should_have_readonly_attributes(*attributes)
        get_options!(attributes)
        klass = model_class

        attributes.each do |attribute|
          attribute = attribute.to_sym
          should "make #{attribute} read-only" do
            readonly = klass.readonly_attributes || []

            assert readonly.include?(attribute.to_s),
                   (readonly.empty? ?
                     "#{klass} attribute #{attribute} is not read-only" :
                     "#{klass} is making #{readonly.to_a.to_sentence} read-only, but not #{attribute}.")
          end
        end
      end

      # Ensures that the attribute cannot be set to the given values
      #
      # If an instance variable has been created in the setup named after the
      # model being tested, then this method will use that.  Otherwise, it will
      # create a new instance to test against.
      #
      # Options:
      # * <tt>:message</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt>.
      #   Regexp or string.  Default = <tt>I18n.translate('activerecord.errors.messages.invalid')</tt>
      #
      # Example:
      #   should_not_allow_values_for :isbn, "bad 1", "bad 2"
      #
      def should_not_allow_values_for(attribute, *bad_values)
        message = get_options!(bad_values, :message)
        klass = model_class
        bad_values.each do |value|
          matcher = allow_value(value).for(attribute).with_message(message)
          should "not #{matcher.description}" do
            assert_rejects matcher, get_instance_of(klass)
          end
        end
      end

      # Ensures that the attribute can be set to the given values.
      #
      # If an instance variable has been created in the setup named after the
      # model being tested, then this method will use that.  Otherwise, it will
      # create a new instance to test against.
      #
      # Example:
      #   should_allow_values_for :isbn, "isbn 1 2345 6789 0", "ISBN 1-2345-6789-0"
      #
      def should_allow_values_for(attribute, *good_values)
        get_options!(good_values)
        klass = model_class
        klass = model_class
        good_values.each do |value|
          matcher = allow_value(value).for(attribute)
          should matcher.description do
            assert_accepts matcher, get_instance_of(klass)
          end
        end
      end

      # Ensures that the length of the attribute is in the given range
      #
      # If an instance variable has been created in the setup named after the
      # model being tested, then this method will use that.  Otherwise, it will
      # create a new instance to test against.
      #
      # Options:
      # * <tt>:short_message</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt>.
      #   Regexp or string.  Default = <tt>I18n.translate('activerecord.errors.messages.too_short') % range.first</tt>
      # * <tt>:long_message</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt>.
      #   Regexp or string.  Default = <tt>I18n.translate('activerecord.errors.messages.too_long') % range.last</tt>
      #
      # Example:
      #   should_ensure_length_in_range :password, (6..20)
      #
      def should_ensure_length_in_range(attribute, range, opts = {})
        short_message, long_message = get_options!([opts], 
                                                   :short_message,
                                                   :long_message)
        klass = model_class

        matcher = ensure_length_of(attribute).
          is_at_least(range.first).
          with_short_message(short_message).
          is_at_most(range.last).
          with_long_message(long_message)

        should matcher.description do
          assert_accepts matcher, get_instance_of(klass)
        end
      end

      # Ensures that the length of the attribute is at least a certain length
      #
      # If an instance variable has been created in the setup named after the
      # model being tested, then this method will use that.  Otherwise, it will
      # create a new instance to test against.
      #
      # Options:
      # * <tt>:short_message</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt>.
      #   Regexp or string.  Default = <tt>I18n.translate('activerecord.errors.messages.too_short') % min_length</tt>
      #
      # Example:
      #   should_ensure_length_at_least :name, 3
      #
      def should_ensure_length_at_least(attribute, min_length, opts = {})
        short_message = get_options!([opts], :short_message)
        klass = model_class

        matcher = ensure_length_of(attribute).
          is_at_least(min_length).
          with_short_message(short_message)

        should matcher.description do
          assert_accepts matcher, get_instance_of(klass)
        end
      end

      # Ensures that the length of the attribute is exactly a certain length
      #
      # If an instance variable has been created in the setup named after the
      # model being tested, then this method will use that.  Otherwise, it will
      # create a new instance to test against.
      #
      # Options:
      # * <tt>:message</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt>.
      #   Regexp or string.  Default = <tt>I18n.translate('activerecord.errors.messages.wrong_length') % length</tt>
      #
      # Example:
      #   should_ensure_length_is :ssn, 9
      #
      def should_ensure_length_is(attribute, length, opts = {})
        message = get_options!([opts], :message)
        klass   = model_class
        matcher = ensure_length_of(attribute).
          is_equal_to(length).
          with_message(message)

        should matcher.description do
          assert_accepts matcher, get_instance_of(klass)
        end
      end

      # Ensure that the attribute is in the range specified
      #
      # If an instance variable has been created in the setup named after the
      # model being tested, then this method will use that.  Otherwise, it will
      # create a new instance to test against.
      #
      # Options:
      # * <tt>:low_message</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt>.
      #   Regexp or string.  Default = <tt>I18n.translate('activerecord.errors.messages.inclusion')</tt>
      # * <tt>:high_message</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt>.
      #   Regexp or string.  Default = <tt>I18n.translate('activerecord.errors.messages.inclusion')</tt>
      #
      # Example:
      #   should_ensure_value_in_range :age, (0..100)
      #
      def should_ensure_value_in_range(attribute, range, opts = {})
        message = get_options!([opts], :message)
        message ||= default_error_message(:inclusion)

        klass = model_class
        matcher = ensure_inclusion_of(attribute).
          in_range(range).
          with_message(message)
        should matcher.description do
          assert_accepts matcher, get_instance_of(klass)
        end
      end

      # Ensure that the attribute is numeric
      #
      # If an instance variable has been created in the setup named after the
      # model being tested, then this method will use that.  Otherwise, it will
      # create a new instance to test against.
      #
      # Options:
      # * <tt>:message</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt>.
      #   Regexp or string.  Default = <tt>I18n.translate('activerecord.errors.messages.not_a_number')</tt>
      #
      # Example:
      #   should_only_allow_numeric_values_for :age
      #
      def should_only_allow_numeric_values_for(*attributes)
        message = get_options!(attributes, :message)
        message ||= default_error_message(:not_a_number)
        klass = model_class
        attributes.each do |attribute|
          attribute = attribute.to_sym
          should "only allow numeric values for #{attribute}" do
            assert_bad_value(klass, attribute, "abcd", message)
          end
        end
      end

      # Ensures that the has_many relationship exists.  Will also test that the
      # associated table has the required columns.  Works with polymorphic
      # associations.
      #
      # Options:
      # * <tt>:through</tt> - association name for <tt>has_many :through</tt>
      # * <tt>:dependent</tt> - tests that the association makes use of the dependent option.
      #
      # Example:
      #   should_have_many :friends
      #   should_have_many :enemies, :through => :friends
      #   should_have_many :enemies, :dependent => :destroy
      #
      def should_have_many(*associations)
        through, dependent = get_options!(associations, :through, :dependent)
        klass = model_class
        associations.each do |association|
          matcher = have_many(association).through(through).dependent(dependent)
          should matcher.description do
            assert_accepts(matcher, klass.new)
          end
        end
      end

      # Ensure that the has_one relationship exists.  Will also test that the
      # associated table has the required columns.  Works with polymorphic
      # associations.
      #
      # Options:
      # * <tt>:dependent</tt> - tests that the association makes use of the dependent option.
      #
      # Example:
      #   should_have_one :god # unless hindu
      #
      def should_have_one(*associations)
        dependent = get_options!(associations, :dependent)
        klass = model_class
        associations.each do |association|
          matcher = have_one(association).dependent(dependent)
          should matcher.description do
            assert_accepts(matcher, klass.new)
          end
        end
      end

      # Ensures that the has_and_belongs_to_many relationship exists, and that the join
      # table is in place.
      #
      #   should_have_and_belong_to_many :posts, :cars
      #
      def should_have_and_belong_to_many(*associations)
        get_options!(associations)
        klass = model_class

        associations.each do |association|
          matcher = have_and_belong_to_many(association)
          should matcher.description do
            assert_accepts(matcher, klass.new)
          end
        end
      end

      # Ensure that the belongs_to relationship exists.
      #
      #   should_belong_to :parent
      #
      def should_belong_to(*associations)
        dependent = get_options!(associations, :dependent)
        klass = model_class
        associations.each do |association|
          matcher = belong_to(association).dependent(dependent)
          should matcher.description do
            assert_accepts(matcher, klass.new)
          end
        end
      end

      # Ensure that the given class methods are defined on the model.
      #
      #   should_have_class_methods :find, :destroy
      #
      def should_have_class_methods(*methods)
        get_options!(methods)
        klass = model_class
        methods.each do |method|
          should "respond to class method ##{method}" do
            assert_respond_to klass, method, "#{klass.name} does not have class method #{method}"
          end
        end
      end

      # Ensure that the given instance methods are defined on the model.
      #
      #   should_have_instance_methods :email, :name, :name=
      #
      def should_have_instance_methods(*methods)
        get_options!(methods)
        klass = model_class
        methods.each do |method|
          should "respond to instance method ##{method}" do
            assert_respond_to klass.new, method, "#{klass.name} does not have instance method #{method}"
          end
        end
      end

      # Ensure that the given columns are defined on the models backing SQL table.
      #
      #   should_have_db_columns :id, :email, :name, :created_at
      #
      def should_have_db_columns(*columns)
        column_type = get_options!(columns, :type)
        klass = model_class
        columns.each do |name|
          test_name = "have column #{name}"
          test_name += " of type #{column_type}" if column_type
          should test_name do
            column = klass.columns.detect {|c| c.name == name.to_s }
            assert column, "#{klass.name} does not have column #{name}"
          end
        end
      end

      # Ensure that the given column is defined on the models backing SQL table.  The options are the same as
      # the instance variables defined on the column definition:  :precision, :limit, :default, :null,
      # :primary, :type, :scale, and :sql_type.
      #
      #   should_have_db_column :email, :type => "string", :default => nil,   :precision => nil, :limit    => 255,
      #                                 :null => true,     :primary => false, :scale     => nil, :sql_type => 'varchar(255)'
      #
      def should_have_db_column(name, opts = {})
        klass = model_class
        test_name = "have column named :#{name}"
        test_name += " with options " + opts.inspect unless opts.empty?
        should test_name do
          column = klass.columns.detect {|c| c.name == name.to_s }
          assert column, "#{klass.name} does not have column #{name}"
          opts.each do |k, v|
            assert_equal column.instance_variable_get("@#{k}").to_s, v.to_s, ":#{name} column on table for #{klass} does not match option :#{k}"
          end
        end
      end

      # Ensures that there are DB indices on the given columns or tuples of columns.
      # Also aliased to should_have_index for readability
      #
      # Options:
      # * <tt>:unique</tt> - whether or not the index has a unique
      #   constraint. Use <tt>true</tt> to explicitly test for a unique
      #   constraint.  Use <tt>false</tt> to explicitly test for a non-unique
      #   constraint. Use <tt>nil</tt> if you don't care whether the index is
      #   unique or not.  Default = <tt>nil</tt>
      #
      # Examples:
      #
      #   should_have_indices :email, :name, [:commentable_type, :commentable_id]
      #   should_have_index :age
      #   should_have_index :ssn, :unique => true
      #
      def should_have_indices(*columns)
        unique = get_options!(columns, :unique)
        table = model_class.table_name
        indices = ::ActiveRecord::Base.connection.indexes(table)
        index_types = { true => "unique", false => "non-unique" }
        index_type = index_types[unique] || "an"

        columns.each do |column|
          should "have #{index_type} index on #{table} for #{column.inspect}" do
            columns = [column].flatten.map(&:to_s)
            index = indices.detect {|ind| ind.columns == columns }
            assert index, "#{table} does not have an index for #{column.inspect}"
            if [true, false].include?(unique)
              assert_equal unique, index.unique, "Expected #{index_type} index but was #{index_types[index.unique]}."
            end
          end
        end
      end

      alias_method :should_have_index, :should_have_indices

      # Ensures that the model cannot be saved if one of the attributes listed is not accepted.
      #
      # If an instance variable has been created in the setup named after the
      # model being tested, then this method will use that.  Otherwise, it will
      # create a new instance to test against.
      #
      # Options:
      # * <tt>:message</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt>.
      #   Regexp or string.  Default = <tt>I18n.translate('activerecord.errors.messages.accepted')</tt>
      #
      # Example:
      #   should_require_acceptance_of :eula
      #
      def should_require_acceptance_of(*attributes)
        message = get_options!(attributes, :message)
        message ||= default_error_message(:accepted)
        klass = model_class

        attributes.each do |attribute|
          should "require #{attribute} to be accepted" do
            assert_bad_value(klass, attribute, false, message)
          end
        end
      end

      # Ensures that the model has a method named scope_name that returns a NamedScope object with the
      # proxy options set to the options you supply.  scope_name can be either a symbol, or a method
      # call which will be evaled against the model.  The eval'd method call has access to all the same
      # instance variables that a should statement would.
      #
      # Options: Any of the options that the named scope would pass on to find.
      #
      # Example:
      #
      #   should_have_named_scope :visible, :conditions => {:visible => true}
      #
      # Passes for
      #
      #   named_scope :visible, :conditions => {:visible => true}
      #
      # Or for
      #
      #   def self.visible
      #     scoped(:conditions => {:visible => true})
      #   end
      #
      # You can test lambdas or methods that return ActiveRecord#scoped calls:
      #
      #   should_have_named_scope 'recent(5)', :limit => 5
      #   should_have_named_scope 'recent(1)', :limit => 1
      #
      # Passes for
      #   named_scope :recent, lambda {|c| {:limit => c}}
      #
      # Or for
      #
      #   def self.recent(c)
      #     scoped(:limit => c)
      #   end
      #
      def should_have_named_scope(scope_call, *args)
        klass = model_class
        scope_opts = args.extract_options!
        scope_call = scope_call.to_s

        context scope_call do
          setup do
            @scope = eval("#{klass}.#{scope_call}")
          end

          should "return a scope object" do
            assert_equal ::ActiveRecord::NamedScope::Scope, @scope.class
          end

          unless scope_opts.empty?
            should "scope itself to #{scope_opts.inspect}" do
              assert_equal scope_opts, @scope.proxy_options
            end
          end
        end
      end
    end
  end
end
