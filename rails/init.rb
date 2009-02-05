if RAILS_ENV == 'test'
  if defined? Spec
    require 'shoulda/rspec'
  else
    require 'shoulda/rails' 
  end
end
