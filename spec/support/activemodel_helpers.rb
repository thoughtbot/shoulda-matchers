module ActiveModelHelpers
  def custom_validation(&block)
    define_model(:example, :attr => :integer) do
      validate :custom_validation

      define_method(:custom_validation, &block)
    end.new
  end

  def validating_format(options)
    define_model :example, :attr => :string do
      validates_format_of :attr, options
    end.new
  end

  module NumericalityHelpers
    def instance_with_validations(options = {})
      define_model :example, :attr => :string do
        validates_numericality_of :attr, options
        attr_accessible :attr
      end.new
    end

    def instance_without_validations
      define_model :example, :attr => :string do
        attr_accessible :attr
      end.new
    end

    def matcher
      validate_numericality_of(:attr)
    end
  end
end

RSpec.configure do |c|
  c.include ActiveModelHelpers
end
