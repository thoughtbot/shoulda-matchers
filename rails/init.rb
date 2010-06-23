if RAILS_ENV == 'test'
  if defined? Spec
    require 'shoulda/integrations/rspec'
  else
    require 'shoulda/integrations/test_unit'
    Shoulda.autoload_macros RAILS_ROOT, File.join("vendor", "{plugins,gems}", "*")
  end
end
