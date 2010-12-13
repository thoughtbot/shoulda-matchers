module CustomMacro
  def custom_macro
  end
end
ActiveSupport::TestCase.extend(CustomMacro)

