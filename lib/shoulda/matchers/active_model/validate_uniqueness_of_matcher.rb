module Shoulda # :nodoc:
  module Matchers
    module ActiveModel # :nodoc:
      # Ensures that the model is invalid if the given attribute is not unique.
      # It uses the first existing record or creates a new one if no record
      # exists in the database. It simply uses `:validate => false` to get
      # around validations, so it will probably fail if there are `NOT NULL`
      # constraints. In that case, you must create a record before calling
      # `validate_uniqueness_of`.
      #
      # Example:
      #   it { should validate_uniqueness_of(:email) }
      #
      # Options:
      #
      # * <tt>with_message</tt> - value the test expects to find in
      #   <tt>errors.on(:attribute)</tt>. <tt>Regexp</tt> or <tt>String</tt>.
      #   Defaults to the translation for <tt>:taken</tt>.
      # * <tt>scoped_to</tt> - field(s) to scope the uniqueness to.
      # * <tt>case_insensitive</tt> - ensures that the validation does not
      #   check case. Off by default. Ignored by non-text attributes.
      #
      # Examples:
      #   it { should validate_uniqueness_of(:keyword) }
      #   it { should validate_uniqueness_of(:keyword).with_message(/dup/) }
      #   it { should validate_uniqueness_of(:email).scoped_to(:name) }
      #   it { should validate_uniqueness_of(:email).
      #                 scoped_to(:first_name, :last_name) }
      #   it { should validate_uniqueness_of(:keyword).case_insensitive }
      #
      def validate_uniqueness_of(attr)
        ValidateUniquenessOfMatcher.new(attr)
      end

      class ValidateUniquenessOfMatcher < ValidationMatcher # :nodoc:
        include Helpers

        def initialize(attribute)
          super(attribute)
          @options = {}
        end

        def scoped_to(*scopes)
          @options[:scopes] = [*scopes].flatten
          self
        end

        def with_message(message)
          @expected_message = message
          self
        end

        def case_insensitive
          @options[:case_insensitive] = true
          self
        end

        def matches?(subject)
          @subject = subject.class.new
          @expected_message ||= :taken
          set_scoped_attributes &&
            validate_attribute? &&
            validate_after_scope_change?
        end

        def description
          result = 'require '
          result << 'case sensitive ' unless @options[:case_insensitive]
          result << "unique value for #{@attribute}"
          result << " scoped to #{@options[:scopes].join(', ')}" if @options[:scopes].present?
          result
        end

        private

        def existing
          @existing ||= first_instance
        end

        def first_instance
          @subject.class.first || create_instance_in_database
        end

        def create_instance_in_database
          @subject.class.new.tap do |instance|
            instance.send("#{@attribute}=", 'arbitrary_string')
            instance.save(:validate => false)
          end
        end

        def set_scoped_attributes
          if @options[:scopes].present?
            @options[:scopes].all? do |scope|
              setter = :"#{scope}="
              if @subject.respond_to?(setter)
                @subject.send(setter, existing.send(scope))
                true
              else
                @failure_message_for_should = "#{class_name} doesn't seem to have a #{scope} attribute."
                false
              end
            end
          else
            true
          end
        end

        def validate_attribute?
          disallows_value_of(existing_value, @expected_message)
        end

        # TODO:  There is a chance that we could change the scoped field
        # to a value that's already taken.  An alternative implementation
        # could actually find all values for scope and create a unique
        def validate_after_scope_change?
          if @options[:scopes].blank?
            true
          else
            @options[:scopes].all? do |scope|
              previous_value = existing.send(scope)

              # Assume the scope is a foreign key if the field is nil
              previous_value ||= correct_type_for_column(@subject.class.columns_hash[scope.to_s])

              next_value = if previous_value.respond_to?(:next)
                previous_value.next
              else
                previous_value.to_s.next
              end

              @subject.send("#{scope}=", next_value)

              if allows_value_of(existing_value, @expected_message)
                @subject.send("#{scope}=", previous_value)

                @failure_message_for_should_not <<
                  " (with different value of #{scope})"
                true
              else
                @failure_message_for_should << " (with different value of #{scope})"
                false
              end
            end
          end
        end

        def correct_type_for_column(column)
          if column.type == :string
            '0'
          else
            0
          end
        end

        def class_name
          @subject.class.name
        end

        def existing_value
          value = existing.send(@attribute)
          if @options[:case_insensitive] && value.respond_to?(:swapcase!)
            value.swapcase!
          end
          value
        end
      end
    end
  end
end
