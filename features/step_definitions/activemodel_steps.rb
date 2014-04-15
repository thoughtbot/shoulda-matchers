When 'I generate a new ActiveModel application' do
  steps %{
    When I run `mkdir #{APP_NAME}`
    And I cd to "#{APP_NAME}"
    And I run `bundle init`
  }

  # Figure out the ActiveModel version to use by reusing the Rails version from
  # the Appraise gemfile.
  if match = File.read(ENV['BUNDLE_GEMFILE']).match(/^gem "rails", "(.*)"/)
    append_to_gemfile %(gem 'activemodel', '#{ match[1] }')
  else
    puts "Couldn't determine which ActiveModel version to load; using latest"
    append_to_gemfile %(gem 'activemodel')
  end

  steps %{
    And I set the "BUNDLE_GEMFILE" environment variable to "Gemfile"
    And I install gems
  }
end
