$LOAD_PATH << File.join(File.dirname(__FILE__), 'lib')
require 'shoulda/matchers/version'

Gem::Specification.new do |s|
  s.name        = "shoulda-matchers"
  s.version     = Shoulda::Matchers::VERSION.dup
  s.authors     = ["Tammer Saleh", "Joe Ferris", "Ryan McGeary", "Dan Croak",
                   "Matt Jankowski", "Stafford Brunk"]
  s.date        = Time.now.strftime("%Y-%m-%d")
  s.email       = "support@thoughtbot.com"
  s.homepage    = "http://thoughtbot.com/community/"
  s.summary     = "Making tests easy on the fingers and eyes"
  s.description = "Making tests easy on the fingers and eyes"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency('mocha',       '~> 0.10.5')
  s.add_development_dependency('rspec-rails', '~> 2.6.1')
  s.add_development_dependency('cucumber',    '~> 1.1.9')
  s.add_development_dependency('aruba')
  s.add_development_dependency('appraisal',   '~> 0.4.0')
  s.add_development_dependency('rake',        '~> 0.9.2')
  s.add_development_dependency('bundler',     '~> 1.1.0')
  s.add_development_dependency('rails',       '~> 3.0')
end
