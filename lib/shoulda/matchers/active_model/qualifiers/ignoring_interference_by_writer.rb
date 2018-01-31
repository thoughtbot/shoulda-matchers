module Shoulda
  module Matchers
    module ActiveModel
      module Qualifiers
        # @private
        module IgnoringInterferenceByWriter
          def ignoring_interference_by_writer(value = :always)
            ignore_interference_by_writer.set(value)
            self
          end

          # This can't be protected, otherwise we get a warning from Forwardable
          def ignore_interference_by_writer
            @_ignore_interference_by_writer ||= IgnoreInterferenceByWriter.new
          end
        end
      end
    end
  end
end
