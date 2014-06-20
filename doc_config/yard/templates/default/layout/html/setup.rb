def stylesheets
  %w(css/solarized.css css/bootstrap.css css/global.css) + super
end

def javascripts
  javascripts = super
  javascripts.insert 1, 'js/jquery.stickyheaders.js', 'js/underscore.min.js'
end
