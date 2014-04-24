module RailsVersions
  def rails_version
    Gem::Version.new(Rails::VERSION::STRING)
  end

  def rails_3_x?
    Gem::Requirement.new('~> 3.0').satisfied_by?(rails_version)
  end

  def rails_4_x?
    Gem::Requirement.new('~> 4.0').satisfied_by?(rails_version)
  end

  def rails_gte_4_1?
    Gem::Requirement.new('>= 4.1').satisfied_by?(rails_version)
  end
end

RSpec.configure do |config|
  config.include(RailsVersions)
  config.extend(RailsVersions)
end
