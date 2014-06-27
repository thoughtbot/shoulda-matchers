require File.expand_path('../warnings_spy', __FILE__)

# Adapted from <http://myronmars.to/n/dev-blog/2011/08/making-your-gem-warning-free>

warnings_spy = WarningsSpy.new('shoulda-matchers')
warnings_spy.capture_warnings
warnings_spy.report_warnings_at_exit
