def stylesheets_full_list
  %w(css/solarized.css css/bootstrap.css css/global.css) + super
end

def javascripts
  javascripts = super
  javascripts.insert 1, 'js/jquery.stickyheaders.js'
end
