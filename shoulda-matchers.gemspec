$LOAD_PATH << File.join(File.dirname(__FILE__), 'lib')
require 'shoulda/matchers/version'

Gem::Specification.new do |s|
  s.name = %q{shoulda-matchers}
  s.version = Shoulda::Matchers::VERSION.dup

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Tammer Saleh", "Joe Ferris", "Ryan McGeary", "Dan Croak",
    "Matt Jankowski"]
  s.date = Time.now.strftime("%Y-%m-%d")
  s.email = %q{support@thoughtbot.com}
  s.extra_rdoc_files = ["README.rdoc", "CONTRIBUTION_GUIDELINES.rdoc"]
  s.files = Dir["[A-Z]*", "{bin,lib,rails,test}/**/*"]
  s.homepage = %q{http://thoughtbot.com/community/}
  s.rdoc_options = ["--line-numbers", "--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Making tests easy on the fingers and eyes}
  s.description = %q{Making tests easy on the fingers and eyes}

  s.add_development_dependency("sqlite3-ruby", "~> 1.3.2")
  s.add_development_dependency("mocha", "~> 0.9.10")
  s.add_development_dependency("rspec-rails", "~> 2.6.1.beta1")
  s.add_development_dependency("cucumber", "~> 0.10.0")
  s.add_development_dependency("appraisal", "~> 0.3.3")

  if RUBY_VERSION >= "1.9"
    s.add_development_dependency("ruby-debug19", "~> 0.11.6")
  else
    s.add_development_dependency("ruby-debug", "~> 0.10.4")
  end

  if s.respond_to? :specification_version then
    s.specification_version = 3
  else
  end
end
