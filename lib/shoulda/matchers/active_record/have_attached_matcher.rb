module Shoulda
  module Matchers
    module ActiveRecord
      # The `have_one_attached` matcher tests usage of the
      # `has_one_attached` macro.
      #
      # #### Example
      #
      #     class User < ApplicationRecord
      #       has_one_attached :avatar
      #     end
      #
      #     # RSpec
      #     RSpec.describe User, type: :model do
      #       it { should have_one_attached(:avatar) }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class UserTest < ActiveSupport::TestCase
      #       should have_one_attached(:avatar)
      #     end
      #
      # #### Qualifiers
      #
      # ##### service
      #
      # Use `service` to assert that the `:service` option was specified.
      #
      #     class User < ApplicationRecord
      #       has_one_attached :avatar, service: :s3
      #     end
      #
      #     # RSpec
      #     RSpec.describe User, type: :model do
      #       it { should have_one_attached(:avatar).service(:s3) }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class UserTest < ActiveSupport::TestCase
      #       should have_one_attached(:avatar).service(:s3)
      #     end
      #
      # ##### dependent
      #
      # Use `dependent` to assert that the `:dependent` option was specified.
      #
      #     class User < ApplicationRecord
      #       has_one_attached :avatar, dependent: :destroy
      #     end
      #
      #     # RSpec
      #     RSpec.describe User, type: :model do
      #       it { should have_one_attached(:avatar).dependent(:destroy) }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class UserTest < ActiveSupport::TestCase
      #       should have_one_attached(:avatar).dependent(:destroy)
      #     end
      #
      # ##### strict_loading
      #
      # Use `strict_loading` to assert that the `:strict_loading` option was specified.
      #
      #     class User < ApplicationRecord
      #       has_one_attached :avatar, strict_loading: true
      #     end
      #
      #     # RSpec
      #     RSpec.describe User, type: :model do
      #       it { should have_one_attached(:avatar).strict_loading(true) }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class UserTest < ActiveSupport::TestCase
      #       should have_one_attached(:avatar).strict_loading(true)
      #     end
      #
      # Default value is true when no argument is specified:
      #
      #     # RSpec
      #     RSpec.describe User, type: :model do
      #       it { should have_one_attached(:avatar).strict_loading }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class UserTest < ActiveSupport::TestCase
      #       should have_one_attached(:avatar).strict_loading
      #     end
      #
      # @return [HaveAttachedMatcher]
      #
      def have_one_attached(name)
        HaveAttachedMatcher.new(:one, name)
      end

      # The `have_many_attached` matcher tests usage of the
      # `has_many_attached` macro.
      #
      # #### Example
      #
      #     class Message < ApplicationRecord
      #       has_many_attached :images
      #     end
      #
      #     # RSpec
      #     RSpec.describe Message, type: :model do
      #       it { should have_many_attached(:images) }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class MessageTest < ActiveSupport::TestCase
      #       should have_many_attached(:images)
      #     end
      #
      # @return [HaveAttachedMatcher]
      #
      def have_many_attached(name)
        HaveAttachedMatcher.new(:many, name)
      end

      # @private
      class HaveAttachedMatcher
        attr_reader :name, :options

        def initialize(macro, name)
          @macro = macro
          @name = name
          @options = {}
        end

        def description
          "have a has_#{macro}_attached called #{name}"
        end

        def failure_message
          <<-MESSAGE
Expected #{expectation}, but this could not be proved.
  #{@failure}
          MESSAGE
        end

        def failure_message_when_negated
          <<-MESSAGE
Did not expect #{expectation}, but it does.
          MESSAGE
        end

        def expectation
          "#{model_class.name} to #{description}" + build_expectation_suffix
        end

        def matches?(subject)
          @subject = subject
          reader_attribute_exists? &&
            writer_attribute_exists? &&
            attachments_association_exists? &&
            blobs_association_exists? &&
            eager_loading_scope_exists? &&
            service_correct? &&
            dependent_option_correct?
        end

        OPTION_METHODS = {
          service: -> (value) { value },
          strict_loading: -> (value = true) { value },
          dependent: -> (value) { value },
        }.freeze

        OPTION_METHODS.each do |option_name, value_processor|
          define_method(option_name) do |*args|
            @options[option_name] = value_processor.call(*args)
            self
          end
        end

        private

        attr_reader :subject, :macro

        def build_expectation_suffix
          String.new.tap do |suffix|
            suffix << " with service :#{options[:service]}" if options.key?(:service)

            if options.key?(:strict_loading)
              suffix << " with strict_loading option set to #{options[:strict_loading]}"
            end

            if options.key?(:dependent)
              suffix << " with dependent option set to :#{options[:dependent]}"
            end
          end
        end

        def reader_attribute_exists?
          if subject.respond_to?(name)
            true
          else
            @failure = "#{model_class.name} does not have a :#{name} method."
            false
          end
        end

        def writer_attribute_exists?
          if subject.respond_to?("#{name}=")
            true
          else
            @failure = "#{model_class.name} does not have a :#{name}= method."
            false
          end
        end

        def attachments_association_exists?
          if attachments_association_matcher.matches?(subject)
            true
          else
            @failure = attachments_association_matcher.failure_message
            false
          end
        end

        def attachments_association_matcher
          @_attachments_association_matcher ||=
            AssociationMatcher.new(
              :"has_#{macro}",
              attachments_association_name,
            ).
              conditions(name:).
              class_name('ActiveStorage::Attachment').
              inverse_of(:record)
        end

        def attachments_association_name
          case macro
          when :one then "#{name}_attachment"
          when :many then "#{name}_attachments"
          end
        end

        def blobs_association_exists?
          if blobs_association_matcher.matches?(subject)
            true
          else
            @failure = blobs_association_matcher.failure_message
            false
          end
        end

        def blobs_association_matcher
          @_blobs_association_matcher ||=
            AssociationMatcher.new(
              :"has_#{macro}",
              blobs_association_name,
            ).
              through(attachments_association_name).
              class_name('ActiveStorage::Blob').
              strict_loading(options[:strict_loading]).
              source(:blob)
        end

        def blobs_association_name
          case macro
          when :one then "#{name}_blob"
          when :many then "#{name}_blobs"
          end
        end

        def eager_loading_scope_exists?
          if model_class.respond_to?("with_attached_#{name}")
            true
          else
            @failure = "#{model_class.name} does not have a " \
                       ":with_attached_#{name} scope."
            false
          end
        end

        def model_class
          subject.class
        end

        def dependent_option_correct?
          dependent = @options[:dependent]
          return true if dependent.nil? || dependent_option == dependent

          @failure = 'The dependent option for the association called ' \
                      "#{attachments_association_name} is incorrect " \
                      "(expected: :#{dependent}, " \
                      "actual: :#{dependent_option})"
          false
        end

        def service_correct?
          service = @options[:service]
          return true if service.nil? || service_name == service

          @failure = 'The service for the association called ' \
                      "#{attachments_association_name} is incorrect " \
                      "(expected: :#{service}, " \
                      "actual: :#{service_name})"
          false
        end

        def attachment_reflection
          model_class.attachment_reflections[name.to_s]
        end

        def service_name
          attachment_reflection.options[:service_name]
        end

        def dependent_option
          attachment_reflection.options[:dependent]
        end
      end
    end
  end
end
