module Shoulda
  module Matchers
    module ActiveRecord
      # The `encrypt` matcher tests usage of the
      # `encrypts` macro (Rails 7+ only).
      #
      #     class Survey < ActiveRecord::Base
      #       encrypts :access_code
      #     end
      #
      #     # RSpec
      #     RSpec.describe Survey, type: :model do
      #       it { should encrypt(:access_code) }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class SurveyTest < ActiveSupport::TestCase
      #       should encrypt(:access_code)
      #     end
      #
      # #### Qualifiers
      #
      # ##### deterministic
      #
      #     class Survey < ActiveRecord::Base
      #       encrypts :access_code, deterministic: true
      #     end
      #
      #     # RSpec
      #     RSpec.describe Survey, type: :model do
      #       it { should encrypt(:access_code).deterministic(true) }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class SurveyTest < ActiveSupport::TestCase
      #       should encrypt(:access_code).deterministic(true)
      #     end
      #
      # ##### downcase
      #
      #     class Survey < ActiveRecord::Base
      #       encrypts :access_code, downcase: true
      #     end
      #
      #     # RSpec
      #     RSpec.describe Survey, type: :model do
      #       it { should encrypt(:access_code).downcase(true) }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class SurveyTest < ActiveSupport::TestCase
      #       should encrypt(:access_code).downcase(true)
      #     end
      #
      # ##### ignore_case
      #
      #     class Survey < ActiveRecord::Base
      #       encrypts :access_code, deterministic: true, ignore_case: true
      #     end
      #
      #     # RSpec
      #     RSpec.describe Survey, type: :model do
      #       it { should encrypt(:access_code).ignore_case(true) }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class SurveyTest < ActiveSupport::TestCase
      #       should encrypt(:access_code).ignore_case(true)
      #     end
      #
      # @return [EncryptMatcher]
      #
      def encrypt(value)
        EncryptMatcher.new(value)
      end

      # @private
      class EncryptMatcher
        def initialize(attribute)
          @attribute = attribute.to_sym
          @options = {}
        end

        attr_reader :failure_message, :failure_message_when_negated

        def deterministic(deterministic)
          with_option(:deterministic, deterministic)
        end

        def downcase(downcase)
          with_option(:downcase, downcase)
        end

        def ignore_case(ignore_case)
          with_option(:ignore_case, ignore_case)
        end

        def matches?(subject)
          @subject = subject
          result = encrypted_attributes_included? &&
                   options_correct?(
                     :deterministic,
                     :downcase,
                     :ignore_case,
                   )

          if result
            @failure_message_when_negated = "Did not expect to #{description} of #{class_name}"
            if @options.present?
              @failure_message_when_negated += "
using "
              @failure_message_when_negated += @options.map { |opt, expected|
                ":#{opt} option as ‹#{expected}›"
              }.join(' and
')
            end

            @failure_message_when_negated += ",
but it did"
          end

          result
        end

        def description
          "encrypt :#{@attribute}"
        end

        private

        def encrypted_attributes_included?
          if encrypted_attributes.include?(@attribute)
            true
          else
            @failure_message = "Expected to #{description} of #{class_name}, but it did not"
            false
          end
        end

        def with_option(option_name, value)
          @options[option_name] = value
          self
        end

        def options_correct?(*opts)
          opts.all? do |opt|
            next true unless @options.key?(opt)

            expected = @options[opt]
            actual = encrypted_attribute_scheme.send("#{opt}?")
            next true if expected == actual

            @failure_message = "Expected to #{description} of #{class_name} using :#{opt} option
as ‹#{expected}›, but got ‹#{actual}›"

            false
          end
        end

        def encrypted_attributes
          @_encrypted_attributes ||= @subject.class.encrypted_attributes || []
        end

        def encrypted_attribute_scheme
          @subject.class.type_for_attribute(@attribute).scheme
        end

        def class_name
          @subject.class.name
        end
      end
    end
  end
end
