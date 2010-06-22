if RAILS_ENV == 'test'
  if defined? Spec
    require 'shoulda/rspec'
  else
    require 'shoulda/rails'
    Shoulda.autoload_macros RAILS_ROOT, File.join("vendor", "{plugins,gems}", "*")
  end
end
