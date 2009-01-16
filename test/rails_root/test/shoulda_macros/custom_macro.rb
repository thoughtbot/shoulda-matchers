module CustomMacro
  def custom_macro
  end
end
Test::Unit::TestCase.extend(CustomMacro)

