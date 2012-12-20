module ActiveModelHelpers
  def custom_validation(&block)
    define_model(:example, :attr => :integer) do
      validate :custom_validation

      define_method(:custom_validation, &block)
    end.new
  end
end

RSpec.configure do |c|
  c.include ActiveModelHelpers
end
