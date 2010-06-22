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

      # Deprecated: use ActiveRecord::Matchers#validate_presence_of instead.
      #
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
        ::ActiveSupport::Deprecation.warn("use: should validate_presence_of")
        message = get_options!(attributes, :message)

        attributes.each do |attribute|
          should validate_presence_of(attribute).with_message(message)
        end
      end

      # Deprecated: use ActiveRecord::Matchers#validate_uniqueness_of instead.
      #
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
        ::ActiveSupport::Deprecation.warn("use: should validate_uniqueness_of")
        message, scope, case_sensitive = get_options!(attributes, :message, :scoped_to, :case_sensitive)
        scope = [*scope].compact
        case_sensitive = true if case_sensitive.nil?

        attributes.each do |attribute|
          matcher = validate_uniqueness_of(attribute).
            with_message(message).scoped_to(scope)
          matcher = matcher.case_insensitive unless case_sensitive
          should matcher
        end
      end

      # Deprecated: use ActiveRecord::Matchers#allow_mass_assignment_of instead.
      #
      # Ensures that the attribute can be set on mass update.
      #
      #   should_allow_mass_assignment_of :first_name, :last_name
      #
      def should_allow_mass_assignment_of(*attributes)
        ::ActiveSupport::Deprecation.warn("use: should allow_mass_assignment_of")
        get_options!(attributes)

        attributes.each do |attribute|
          should allow_mass_assignment_of(attribute)
        end
      end

      # Deprecated: use ActiveRecord::Matchers#allow_mass_assignment_of instead.
      #
      # Ensures that the attribute cannot be set on mass update.
      #
      #   should_not_allow_mass_assignment_of :password, :admin_flag
      #
      def should_not_allow_mass_assignment_of(*attributes)
        ::ActiveSupport::Deprecation.warn("use: should_not allow_mass_assignment_of")
        get_options!(attributes)

        attributes.each do |attribute|
          should_not allow_mass_assignment_of(attribute)
        end
      end

      # Deprecated: use ActiveRecord::Matchers#have_readonly_attribute instead.
      #
      # Ensures that the attribute cannot be changed once the record has been created.
      #
      #   should_have_readonly_attributes :password, :admin_flag
      #
      def should_have_readonly_attributes(*attributes)
        ::ActiveSupport::Deprecation.warn("use: should have_readonly_attribute")
        get_options!(attributes)

        attributes.each do |attribute|
          should have_readonly_attribute(attribute)
        end
      end

      # Deprecated: use ActiveRecord::Matchers#allow_value instead.
      #
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
        ::ActiveSupport::Deprecation.warn("use: should_not allow_value")
        message = get_options!(bad_values, :message)
        bad_values.each do |value|
          should_not allow_value(value).for(attribute).with_message(message)
        end
      end

      # Deprecated: use ActiveRecord::Matchers#allow_value instead.
      #
      # Ensures that the attribute can be set to the given values.
      #
      # Example:
      #   should_allow_values_for :isbn, "isbn 1 2345 6789 0", "ISBN 1-2345-6789-0"
      #
      def should_allow_values_for(attribute, *good_values)
        ::ActiveSupport::Deprecation.warn("use: should allow_value")
        get_options!(good_values)
        good_values.each do |value|
          should allow_value(value).for(attribute)
        end
      end

      # Deprecated: use ActiveRecord::Matchers#ensure_length_of instead.
      #
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
        ::ActiveSupport::Deprecation.warn("use: should ensure_length_of.is_at_least.is_at_most")
        short_message, long_message = get_options!([opts],
                                                   :short_message,
                                                   :long_message)
        should ensure_length_of(attribute).
          is_at_least(range.first).
          with_short_message(short_message).
          is_at_most(range.last).
          with_long_message(long_message)
      end

      # Deprecated: use ActiveRecord::Matchers#ensure_length_of instead.
      #
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
        ::ActiveSupport::Deprecation.warn("use: should ensure_length_of.is_at_least")
        short_message = get_options!([opts], :short_message)

        should ensure_length_of(attribute).
          is_at_least(min_length).
          with_short_message(short_message)
      end

      # Deprecated: use ActiveRecord::Matchers#ensure_length_of instead.
      #
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
        ::ActiveSupport::Deprecation.warn("use: should ensure_length_of.is_equal_to")
        message = get_options!([opts], :message)
        should ensure_length_of(attribute).
          is_equal_to(length).
          with_message(message)
      end

      # Deprecated: use ActiveRecord::Matchers#ensure_inclusion_of instead.
      #
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
        ::ActiveSupport::Deprecation.warn("use: should ensure_inclusion_of.in_range")
        message, low_message, high_message = get_options!([opts],
                                                          :message,
                                                          :low_message,
                                                          :high_message)
        should ensure_inclusion_of(attribute).
          in_range(range).
          with_message(message).
          with_low_message(low_message).
          with_high_message(high_message)
      end

      # Deprecated: use ActiveRecord::Matchers#validate_numericality_of instead.
      #
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
        ::ActiveSupport::Deprecation.warn("use: should validate_numericality_of")
        message = get_options!(attributes, :message)
        attributes.each do |attribute|
          should validate_numericality_of(attribute).
            with_message(message)
        end
      end

      # Deprecated: use ActiveRecord::Matchers#have_many instead.
      #
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
        ::ActiveSupport::Deprecation.warn("use: should have_many")
        through, dependent = get_options!(associations, :through, :dependent)
        associations.each do |association|
          should have_many(association).through(through).dependent(dependent)
        end
      end

      # Deprecated: use ActiveRecord::Matchers#have_one instead.
      #
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
        ::ActiveSupport::Deprecation.warn("use: should have_one")
        dependent, through = get_options!(associations, :dependent, :through)
        associations.each do |association|
          should have_one(association).dependent(dependent).through(through)
        end
      end

      # Deprecated: use ActiveRecord::Matchers#have_and_belong_to_many instead.
      #
      # Ensures that the has_and_belongs_to_many relationship exists, and that the join
      # table is in place.
      #
      #   should_have_and_belong_to_many :posts, :cars
      #
      def should_have_and_belong_to_many(*associations)
        ::ActiveSupport::Deprecation.warn("use: should have_and_belong_to_many")
        get_options!(associations)

        associations.each do |association|
          should have_and_belong_to_many(association)
        end
      end

      # Deprecated: use ActiveRecord::Matchers#belong_to instead.
      #
      # Ensure that the belongs_to relationship exists.
      #
      #   should_belong_to :parent
      #
      def should_belong_to(*associations)
        ::ActiveSupport::Deprecation.warn("use: should belong_to")
        dependent = get_options!(associations, :dependent)
        associations.each do |association|
          should belong_to(association).dependent(dependent)
        end
      end

      # Deprecated.
      #
      # Ensure that the given class methods are defined on the model.
      #
      #   should_have_class_methods :find, :destroy
      #
      def should_have_class_methods(*methods)
        ::ActiveSupport::Deprecation.warn
        get_options!(methods)
        klass = described_type
        methods.each do |method|
          should "respond to class method ##{method}" do
            assert_respond_to klass, method, "#{klass.name} does not have class method #{method}"
          end
        end
      end

      # Deprecated.
      #
      # Ensure that the given instance methods are defined on the model.
      #
      #   should_have_instance_methods :email, :name, :name=
      #
      def should_have_instance_methods(*methods)
        ::ActiveSupport::Deprecation.warn
        get_options!(methods)
        klass = described_type
        methods.each do |method|
          should "respond to instance method ##{method}" do
            assert_respond_to klass.new, method, "#{klass.name} does not have instance method #{method}"
          end
        end
      end

      # Deprecated: use ActiveRecord::Matchers#have_db_column instead.
      #
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
        ::ActiveSupport::Deprecation.warn("use: should have_db_column")
        column_type, precision, limit, default, null, scale, sql_type =
          get_options!(columns, :type, :precision, :limit,
                                :default, :null, :scale, :sql_type)
        columns.each do |name|
          should have_db_column(name).
                      of_type(column_type).
                      with_options(:precision => precision, :limit    => limit,
                                   :default   => default,   :null     => null,
                                   :scale     => scale,     :sql_type => sql_type)
        end
      end

      alias_method :should_have_db_column, :should_have_db_columns

      # Deprecated: use ActiveRecord::Matchers#have_db_index instead.
      #
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
        ::ActiveSupport::Deprecation.warn("use: should have_db_index")
        unique = get_options!(columns, :unique)

        columns.each do |column|
          should have_db_index(column).unique(unique)
        end
      end

      alias_method :should_have_db_index, :should_have_db_indices

      # Deprecated: use ActiveRecord::Matchers#validate_acceptance_of instead.
      #
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
        ::ActiveSupport::Deprecation.warn("use: should validate_acceptance_of")
        message = get_options!(attributes, :message)

        attributes.each do |attribute|
          should validate_acceptance_of(attribute).with_message(message)
        end
      end
    end
  end
end
