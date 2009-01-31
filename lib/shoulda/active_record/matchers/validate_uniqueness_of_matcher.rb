module Shoulda # :nodoc:
  module ActiveRecord # :nodoc:
    module Matchers

      # Ensures that the model is invalid if the given attribute is not unique.
      #
      # Internally, this uses values from existing records to test validations,
      # so this will always fail if you have not saved at least one record for
      # the model being tested, like so:
      #
      #   describe User do
      #     before(:each) { User.create!(:email => 'address@example.com') }
      #     it { should validate_uniqueness_of(:email) }
      #   end
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
          @attribute = attribute
        end

        def scoped_to(*scopes)
          @scopes = [*scopes].flatten
          self
        end

        def with_message(message)
          @expected_message = message
          self
        end

        def case_insensitive
          @case_insensitive = true
          self
        end

        def description
          result = "require "
          result << "case sensitive " unless @case_insensitive
          result << "unique value for #{@attribute}"
          result << " scoped to #{@scopes.join(', ')}" unless @scopes.blank?
          result
        end

        def matches?(subject)
          @subject = subject.class.new
          @expected_message ||= :taken
          find_existing && 
            set_scoped_attributes && 
            validate_attribute &&
            validate_after_scope_change
        end

        private

        def find_existing
          if @existing = @subject.class.find(:first)
            @failure_message = "Can't find first #{class_name}"
            true
          else
            false
          end
        end

        def set_scoped_attributes
          unless @scopes.blank?
            @scopes.each do |scope|
              setter = :"#{scope}="
              unless @subject.respond_to?(setter)
                @failure_message =
                  "#{class_name} doesn't seem to have a #{scope} attribute."
                return false
              end
              @subject.send("#{scope}=", @existing.send(scope))
            end
          end
          true
        end

        def validate_attribute
          disallows_value_of(existing_value, @expected_message)
        end

        # TODO:  There is a chance that we could change the scoped field
        # to a value that's already taken.  An alternative implementation
        # could actually find all values for scope and create a unique
        def validate_after_scope_change
          if @scopes.blank?
            true
          else
            @scopes.all? do |scope|
              previous_value = @existing.send(scope)

              # Assume the scope is a foreign key if the field is nil
              previous_value ||= 0

              next_value = previous_value.next

              @subject.send("#{scope}=", next_value)

              if allows_value_of(existing_value, @expected_message)
                @negative_failure_message << 
                  " (with different value of #{scope})"
                true
              else
                @failure_message << " (with different value of #{scope})"
                false
              end
            end
          end
        end

        def class_name
          @subject.class.name
        end

        def existing_value
          value = @existing.send(@attribute)
          value.swapcase! if @case_insensitive && value.respond_to?(:swapcase!)
          value
        end
      end

    end
  end
end
