require 'shoulda/active_record/matchers'

Spec::Runner.configure do |config|
  config.include Shoulda::ActiveRecord::Matchers, :type => :model
end
