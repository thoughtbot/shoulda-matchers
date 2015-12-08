module Shoulda
  module Matchers
    module ActionController
      # @private
      class FlashStore < Store
        def self.future
          new
        end

        def self.now
          new.use_now!
        end

        def initialize
          @use_now = false
        end

        def name
          if @use_now
            'flash.now'
          else
            'flash'
          end
        end

        def use_now!
          @use_now = true
          self
        end

        def store
          if @use_now
            set_values.slice(*keys_to_discard.to_a)
          else
            set_values.except(*keys_to_discard.to_a)
          end
        end

        private

        def flash
          @_flash ||= copy_of_flash_from_controller
        end

        def copy_of_flash_from_controller
          controller.flash.dup.tap do |flash|
            copy_flashes(controller.flash, flash)
            copy_discard_if_necessary(controller.flash, flash)
          end
        end

        def copy_flashes(original_flash, new_flash)
          flashes = original_flash.instance_variable_get('@flashes').dup
          new_flash.instance_variable_set('@flashes', flashes)
        end

        def copy_discard_if_necessary(original_flash, new_flash)
          discard = original_flash.instance_variable_get('@discard').dup
          new_flash.instance_variable_set('@discard', discard)
        end

        def set_values
          flash.instance_variable_get('@flashes')
        end

        def keys_to_discard
          flash.instance_variable_get('@discard')
        end
      end
    end
  end
end
