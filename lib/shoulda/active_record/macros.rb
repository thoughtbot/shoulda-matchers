module Shoulda # :nodoc:
  module ActiveRecord # :nodoc:
    # = Macro test helpers for your active record models
    #
    # These helpers will test most of the validations and associations for your ActiveRecord models.
    #
    #   class UserTest < Test::Unit::TestCase
    #     should_validate_presence_of :name, :phone_number
    #     should_not_allow_values_for :phone_number, "abcd", "1234"
    #     should_allow_values_for :phone_number, "(123) 456-7890"
    #
    #     should_not_allow_mass_assignment_of :password
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

      # Ensures that the model cannot be saved if one of the attributes listed is not present.
      #
      # Options:
      # * <tt>:message</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt>.
      #   Regexp or string.  Default = <tt>I18n.translate('activerecord.errors.messages.blank')</tt>
      #
      # Example:
      #   should_validate_presence_of :name, :phone_number
      #
      def should_validate_presence_of(*attributes)
        message = get_options!(attributes, :message)

        attributes.each do |attribute|
          matcher = validate_presence_of(attribute).with_message(message)
          should matcher.description do
            assert_accepts(matcher, subject)
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
      #   should_validate_uniqueness_of :keyword, :username
      #   should_validate_uniqueness_of :name, :message => "O NOES! SOMEONE STOELED YER NAME!"
      #   should_validate_uniqueness_of :email, :scoped_to => :name
      #   should_validate_uniqueness_of :address, :scoped_to => [:first_name, :last_name]
      #   should_validate_uniqueness_of :email, :case_sensitive => false
      #
      def should_validate_uniqueness_of(*attributes)
        message, scope, case_sensitive = get_options!(attributes, :message, :scoped_to, :case_sensitive)
        scope = [*scope].compact
        case_sensitive = true if case_sensitive.nil?

        attributes.each do |attribute|
          matcher = validate_uniqueness_of(attribute).
            with_message(message).scoped_to(scope)
          matcher = matcher.case_insensitive unless case_sensitive
          should matcher.description do
            assert_accepts(matcher, subject)
          end
        end
      end

      # Ensures that the attribute can be set on mass update.
      #
      #   should_allow_mass_assignment_of :first_name, :last_name
      #
      def should_allow_mass_assignment_of(*attributes)
        get_options!(attributes)

        attributes.each do |attribute|
          matcher = allow_mass_assignment_of(attribute)
          should matcher.description do
            assert_accepts matcher, subject
          end
        end
      end

      # Ensures that the attribute cannot be set on mass update.
      #
      #   should_not_allow_mass_assignment_of :password, :admin_flag
      #
      def should_not_allow_mass_assignment_of(*attributes)
        get_options!(attributes)

        attributes.each do |attribute|
          matcher = allow_mass_assignment_of(attribute)
          should "not #{matcher.description}" do
            assert_rejects matcher, subject
          end
        end
      end

      # Ensures that the attribute cannot be changed once the record has been created.
      #
      #   should_have_readonly_attributes :password, :admin_flag
      #
      def should_have_readonly_attributes(*attributes)
        get_options!(attributes)

        attributes.each do |attribute|
          matcher = have_readonly_attribute(attribute)
          should matcher.description do
            assert_accepts matcher, subject
          end
        end
      end

      # Ensures that the attribute cannot be set to the given values
      #
      # Options:
      # * <tt>:message</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt>.
      #   Regexp or string. If omitted, the test will pass if there is ANY error in
      #   <tt>errors.on(:attribute)</tt>.
      #
      # Example:
      #   should_not_allow_values_for :isbn, "bad 1", "bad 2"
      #
      def should_not_allow_values_for(attribute, *bad_values)
        message = get_options!(bad_values, :message)
        bad_values.each do |value|
          matcher = allow_value(value).for(attribute).with_message(message)
          should "not #{matcher.description}" do
            assert_rejects matcher, subject
          end
        end
      end

      # Ensures that the attribute can be set to the given values.
      #
      # Example:
      #   should_allow_values_for :isbn, "isbn 1 2345 6789 0", "ISBN 1-2345-6789-0"
      #
      def should_allow_values_for(attribute, *good_values)
        get_options!(good_values)
        good_values.each do |value|
          matcher = allow_value(value).for(attribute)
          should matcher.description do
            assert_accepts matcher, subject
          end
        end
      end

      # Ensures that the length of the attribute is in the given range
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
        matcher = ensure_length_of(attribute).
          is_at_least(range.first).
          with_short_message(short_message).
          is_at_most(range.last).
          with_long_message(long_message)

        should matcher.description do
          assert_accepts matcher, subject
        end
      end

      # Ensures that the length of the attribute is at least a certain length
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

        matcher = ensure_length_of(attribute).
          is_at_least(min_length).
          with_short_message(short_message)

        should matcher.description do
          assert_accepts matcher, subject
        end
      end

      # Ensures that the length of the attribute is exactly a certain length
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
        matcher = ensure_length_of(attribute).
          is_equal_to(length).
          with_message(message)

        should matcher.description do
          assert_accepts matcher, subject
        end
      end

      # Ensure that the attribute is in the range specified
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
        message, low_message, high_message = get_options!([opts],
                                                          :message,
                                                          :low_message,
                                                          :high_message)
        matcher = ensure_inclusion_of(attribute).
          in_range(range).
          with_message(message).
          with_low_message(low_message).
          with_high_message(high_message)
        should matcher.description do
          assert_accepts matcher, subject
        end
      end

      # Ensure that the attribute is numeric
      #
      # Options:
      # * <tt>:message</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt>.
      #   Regexp or string.  Default = <tt>I18n.translate('activerecord.errors.messages.not_a_number')</tt>
      #
      # Example:
      #   should_validate_numericality_of :age
      #
      def should_validate_numericality_of(*attributes)
        message = get_options!(attributes, :message)
        attributes.each do |attribute|
          matcher = validate_numericality_of(attribute).
            with_message(message)
          should matcher.description do
            assert_accepts matcher, subject
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
        associations.each do |association|
          matcher = have_many(association).through(through).dependent(dependent)
          should matcher.description do
            assert_accepts(matcher, subject)
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
        dependent, through = get_options!(associations, :dependent, :through)
        associations.each do |association|
          matcher = have_one(association).dependent(dependent).through(through)
          should matcher.description do
            assert_accepts(matcher, subject)
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

        associations.each do |association|
          matcher = have_and_belong_to_many(association)
          should matcher.description do
            assert_accepts(matcher, subject)
          end
        end
      end

      # Ensure that the belongs_to relationship exists.
      #
      #   should_belong_to :parent
      #
      def should_belong_to(*associations)
        dependent = get_options!(associations, :dependent)
        associations.each do |association|
          matcher = belong_to(association).dependent(dependent)
          should matcher.description do
            assert_accepts(matcher, subject)
          end
        end
      end

      # Ensure that the given class methods are defined on the model.
      #
      #   should_have_class_methods :find, :destroy
      #
      def should_have_class_methods(*methods)
        get_options!(methods)
        klass = described_type
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
        klass = described_type
        methods.each do |method|
          should "respond to instance method ##{method}" do
            assert_respond_to klass.new, method, "#{klass.name} does not have instance method #{method}"
          end
        end
      end

      # Ensure that the given columns are defined on the models backing SQL table.
      # Also aliased to should_have_db_column for readability.
      # Takes the same options available in migrations: 
      # :type, :precision, :limit, :default, :null, and :scale
      #
      # Examples:
      #
      #   should_have_db_columns :id, :email, :name, :created_at
      #
      #   should_have_db_column :email,  :type => "string", :limit => 255
      #   should_have_db_column :salary, :decimal, :precision => 15, :scale => 2
      #   should_have_db_column :admin,  :default => false, :null => false
      #
      def should_have_db_columns(*columns)
        column_type, precision, limit, default, null, scale, sql_type = 
          get_options!(columns, :type, :precision, :limit,
                                :default, :null, :scale, :sql_type)
        columns.each do |name|
          matcher = have_db_column(name).
                      of_type(column_type).
                      with_options(:precision => precision, :limit    => limit,
                                   :default   => default,   :null     => null,
                                   :scale     => scale,     :sql_type => sql_type)
          should matcher.description do
            assert_accepts(matcher, subject)
          end
        end
      end
      
      alias_method :should_have_db_column, :should_have_db_columns

      # Ensures that there are DB indices on the given columns or tuples of columns.
      # Also aliased to should_have_db_index for readability
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
      #   should_have_db_indices :email, :name, [:commentable_type, :commentable_id]
      #   should_have_db_index :age
      #   should_have_db_index :ssn, :unique => true
      #
      def should_have_db_indices(*columns)
        unique = get_options!(columns, :unique)
        
        columns.each do |column|
          matcher = have_db_index(column).unique(unique)
          should matcher.description do
            assert_accepts(matcher, subject)
          end
        end
      end

      alias_method :should_have_db_index, :should_have_db_indices

      # Deprecated. See should_have_db_index
      def should_have_index(*args)
        warn "[DEPRECATION] should_have_index is deprecated. " <<
             "Use should_have_db_index instead."
        should_have_db_index(*args)
      end

      # Deprecated. See should_have_db_indices
      def should_have_indices(*args)
        warn "[DEPRECATION] should_have_indices is deprecated. " <<
             "Use should_have_db_indices instead."
        should_have_db_indices(*args)
      end

      # Ensures that the model cannot be saved if one of the attributes listed is not accepted.
      #
      # Options:
      # * <tt>:message</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt>.
      #   Regexp or string.  Default = <tt>I18n.translate('activerecord.errors.messages.accepted')</tt>
      #
      # Example:
      #   should_validate_acceptance_of :eula
      #
      def should_validate_acceptance_of(*attributes)
        message = get_options!(attributes, :message)

        attributes.each do |attribute|
          matcher = validate_acceptance_of(attribute).with_message(message)
          should matcher.description do
            assert_accepts matcher, subject
          end
        end
      end

      # Deprecated.
      #
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
      def should_have_named_scope(scope_call, find_options = nil)
        matcher = have_named_scope(scope_call).finding(find_options)
        should matcher.description do
          assert_accepts matcher.in_context(self), subject
        end
      end
    end
  end
end
