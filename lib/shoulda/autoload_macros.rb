module Shoulda # :nodoc:
  # Call autoload_macros when you want to load test macros automatically in a non-Rails 
  # project (it's done automatically for Rails projects).
  # You don't need to specify ROOT/test/shoulda_macros explicitly. Your custom macros
  # are loaded automatically when you call autoload_macros.
  #
  # The first argument is the path to you application's root directory.
  # All following arguments are directories relative to your root, which contain 
  # shoulda_macros subdirectories. These directories support the same kinds of globs as the 
  # Dir class.
  # 
  # Basic usage (from a test_helper):
  # Shoulda.autoload_macros(File.dirname(__FILE__) + '/..')
  #	will load everything in 
  #	- your_app/test/shoulda_macros
  #
  #	To load vendored macros as well:
  # Shoulda.autoload_macros(APP_ROOT, 'vendor/*')
  #	will load everything in 
  #	- APP_ROOT/vendor/*/shoulda_macros
  #	- APP_ROOT/test/shoulda_macros
  #
  #	To load macros in an app with a vendor directory laid out like Rails':
  # Shoulda.autoload_macros(APP_ROOT, 'vendor/{plugins,gems}/*')
  # or
  # Shoulda.autoload_macros(APP_ROOT, 'vendor/plugins/*', 'vendor/gems/*')
  #	will load everything in 
  #	- APP_ROOT/vendor/plugins/*/shoulda_macros
  #	- APP_ROOT/vendor/gems/*/shoulda_macros
  #	- APP_ROOT/test/shoulda_macros
  #
  #	If you prefer to stick testing dependencies away from your production dependencies:
  # Shoulda.autoload_macros(APP_ROOT, 'vendor/*', 'test/vendor/*')
  #	will load everything in 
  #	- APP_ROOT/vendor/*/shoulda_macros
  #	- APP_ROOT/test/vendor/*/shoulda_macros
  #	- APP_ROOT/test/shoulda_macros
  def self.autoload_macros(root, *dirs)
    dirs << File.join('test')
    complete_dirs = dirs.map{|d| File.join(root, d, 'shoulda_macros')}
    all_files     = complete_dirs.inject([]){ |files, dir| files + Dir[File.join(dir, '*.rb')] }
    all_files.each do |file|
      require file
    end
  end
end
