module Shoulda # :nodoc:
  module Matchers
    module ActiveModel # :nodoc:
      module UniquenessHelpers
        module TestModels
          def self.new(klass)
            name = klass.dup
            name.next! while self.const_defined?(name)
            self.const_set(name, klass.constantize.dup)
            self.const_get(name)
          end

          def self.teardown
            self.constants.each { |c| self.send(:remove_const, c) }
          end
        end
      end
    end
  end
end