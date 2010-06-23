When /^I generate a new rails application$/ do
  load_rails = <<-RUBY
    gem 'rails', '2.3.8'; \
    load Gem.bin_path('rails', 'rails', '2.3.8')
  RUBY

  @terminal.cd(TEMP_ROOT)
  @terminal.run(%{ruby -rubygems -e "#{load_rails.strip!}" #{APP_NAME}})
end

When /^I configure the application to use "([^\"]+)" from this project$/ do |name|
  gemspec = File.join(PROJECT_ROOT, "#{name}.gemspec")
  eval("$specification = begin; #{IO.read(gemspec)}; end")
  version = $specification.version
  name = $specification.name

  vendor_gem_root = File.join(RAILS_ROOT, 'vendor', 'gems')
  vendor_gem_path = File.join(vendor_gem_root, "shoulda-#{version}")

  FileUtils.mkdir_p(vendor_gem_root)
  FileUtils.ln_s(PROJECT_ROOT, vendor_gem_path)
  File.open(File.join(vendor_gem_path, ".specification"), "w") do |file|
    file.write($specification.to_yaml)
  end

  insert_into_environment("config.gem '#{name}'")
end

When /^I configure the application to use rspec\-rails$/ do
  # we have to unpack and copy the generator because Rails won't find the
  # generators if rspec-rails 2 is installed
  insert_into_environment("config.gem 'rspec-rails', :lib => false, :version => '1.2.9'")
  insert_into_environment("config.gem 'rspec', :lib => false, :version => '1.2.9'")
  steps %{
    When I run "rake gems:unpack"
  }
  rspec_generator = File.join(RAILS_ROOT,
                              'vendor',
                              'gems',
                              'rspec-rails-1.2.9',
                              'generators')
  FileUtils.cp_r(rspec_generator, File.join(RAILS_ROOT, 'lib'))
end

When /^I run the rspec generator$/ do
  steps %{
    When I run the "rspec" generator
  }
end

When /^I run the "([^"]*)" generator$/ do |name|
  steps %{
    When I run "./script/generate #{name}"
  }
end

When /^I configure a wildcard route$/ do
  steps %{
    When I save the following as "config/routes.rb"
    """
    ActionController::Routing::Routes.draw do |map|
      map.connect ':controller/:action/:id'
    end
    """
  }
end

module InsertionHelpers
  def insert_into(path, find, replace)
    contents = IO.read(path)
    contents.sub!(find, replace)
    File.open(path, "w") { |file| file.write(contents) }
  end

  def insert_into_environment(contents)
    environment_file = File.join(RAILS_ROOT, 'config', 'environment.rb')
    initializer = "Rails::Initializer.run do |config|"
    replace = "#{initializer}\n  #{contents}"
    insert_into(environment_file, initializer, replace)
  end
end

World(InsertionHelpers)
