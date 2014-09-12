module RailsHelpers
  RAILS_VERSION_IN_GEMFILE_PATH_REGEX = %r{/([^/]+?)(?:_.+)?\.gemfile$}

  def rails_version_string
    ORIGINAL_BUNDLE_VARS['BUNDLE_GEMFILE'].
      match(RAILS_VERSION_IN_GEMFILE_PATH_REGEX).
      captures[0]
  end

  def rails_version
    @_rails_version ||= Gem::Version.new(rails_version_string)
  end

  def rails_lt_4?
    Gem::Requirement.new('< 4').satisfied_by?(rails_version)
  end

  def rspec_rails_version
    Bundler.definition.specs['rspec-rails'][0].version
  end

  def rspec_rails_gte_3?
    Gem::Requirement.new('>= 3').satisfied_by?(rspec_rails_version)
  end

  def test_helper_path
    if rspec_rails_gte_3?
      'spec/rails_helper.rb'
    else
      'spec/spec_helper.rb'
    end
  end
end

World(RailsHelpers)
