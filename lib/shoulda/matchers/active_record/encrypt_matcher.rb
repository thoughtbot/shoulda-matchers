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
      # ##### with_key_provider
      #
      #     class Survey < ActiveRecord::Base
      #       encrypts :access_code, key_provider: ENCRYPTION_KEY_PROVIDER
      #     end
      #
      #     # RSpec
      #     RSpec.describe Survey, type: :model do
      #       it { should encrypt(:access_code).with_key_provider(ENCRYPTION_KEY_PROVIDER) }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class SurveyTest < ActiveSupport::TestCase
      #       should encrypt(:access_code).with_key_provider(ENCRYPTION_KEY_PROVIDER)
      #     end
      #
      # A class may also be given to assert the kind of key provider used,
      # without holding a reference to the exact instance:
      #
      #     should encrypt(:access_code).
      #       with_key_provider(ActiveRecord::Encryption::DerivedSecretKeyProvider)
      #
      # ##### with_previous
      #
      #     class Survey < ActiveRecord::Base
      #       encrypts :access_code, deterministic: true, previous: { deterministic: false }
      #     end
      #
      #     # RSpec
      #     RSpec.describe Survey, type: :model do
      #       it { should encrypt(:access_code).with_previous(deterministic: false) }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class SurveyTest < ActiveSupport::TestCase
      #       should encrypt(:access_code).with_previous(deterministic: false)
      #     end
      #
      # ##### with_compressor
      #
      #     class Survey < ActiveRecord::Base
      #       encrypts :access_code, compressor: ZstdCompressor
      #     end
      #
      #     # RSpec
      #     RSpec.describe Survey, type: :model do
      #       it { should encrypt(:access_code).with_compressor(ZstdCompressor) }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class SurveyTest < ActiveSupport::TestCase
      #       should encrypt(:access_code).with_compressor(ZstdCompressor)
      #     end
      #
      # ##### without_compression
      #
      #     class Survey < ActiveRecord::Base
      #       encrypts :access_code, compress: false
      #     end
      #
      #     # RSpec
      #     RSpec.describe Survey, type: :model do
      #       it { should encrypt(:access_code).without_compression }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class SurveyTest < ActiveSupport::TestCase
      #       should encrypt(:access_code).without_compression
      #     end
      #
      # ##### supporting_unencrypted_data
      #
      #     class Survey < ActiveRecord::Base
      #       encrypts :access_code, support_unencrypted_data: true
      #     end
      #
      #     # RSpec
      #     RSpec.describe Survey, type: :model do
      #       it { should encrypt(:access_code).supporting_unencrypted_data }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class SurveyTest < ActiveSupport::TestCase
      #       should encrypt(:access_code).supporting_unencrypted_data
      #     end
      #
      # @return [EncryptMatcher]
      #
      def encrypt(value)
        EncryptMatcher.new(value)
      end

      # @private
      class EncryptMatcher
        SCHEME_READERS = {
          deterministic: :deterministic?,
          downcase: :downcase?,
          ignore_case: :ignore_case?,
          key_provider: :key_provider,
          support_unencrypted_data: :support_unencrypted_data?,
          previous: -> (scheme) { scheme.previous_schemes.map(&:to_h) },
          compressor: -> (scheme) {
            properties = scheme.to_h
            encryptor = properties[:encryptor]
            encryptor ? encryptor.compressor : properties[:compressor]
          },
          compress: -> (scheme) {
            properties = scheme.to_h
            encryptor = properties[:encryptor]
            encryptor ? encryptor.compress? : properties.fetch(:compress, true)
          },
        }.freeze

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

        def with_key_provider(key_provider)
          with_option(:key_provider, key_provider)
        end

        def supporting_unencrypted_data
          with_option(:support_unencrypted_data, true)
        end

        def with_previous(*previous)
          with_option(:previous, previous)
        end

        def with_compressor(compressor)
          with_option(:compressor, compressor)
        end

        def without_compression
          with_option(:compress, false)
        end

        def matches?(subject)
          @subject = subject
          result = encrypted_attributes_included? && options_correct?

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

        def scheme_value_for(opt)
          reader = SCHEME_READERS.fetch(opt)

          if reader.respond_to?(:call)
            reader.call(encrypted_attribute_scheme)
          else
            encrypted_attribute_scheme.public_send(reader)
          end
        end

        def option_matches?(expected, actual)
          return true if expected == actual

          expected.is_a?(Module) && actual.is_a?(expected)
        end

        def options_correct?
          @options.all? do |opt, expected|
            actual = scheme_value_for(opt)
            next true if option_matches?(expected, actual)

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
