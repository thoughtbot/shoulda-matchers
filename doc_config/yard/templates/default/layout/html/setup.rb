def stylesheets
  %w(css/solarized.css css/bootstrap.css css/global.css) + super
end

def javascripts
  javascripts = super
  javascripts.insert 1, 'js/jquery.stickyheaders.js', 'js/underscore.min.js'
end

def diskfile
  @file.attributes[:markup] ||= markup_for_file('', @file.filename)

  contents =
    if @file.filename == 'README.md'
      preprocess_index(@file.contents)
    else
      @file.contents
    end

  data = htmlify(contents, @file.attributes[:markup])
  "<div id='filecontents'>#{data}</div>"
end

def preprocess_index(contents)
  regex = /\[ (\w+) \] \( lib \/ ([^()]+) \.rb (?:\#L\d+)? \)/x

  contents.gsub(regex) do
    method_name = $1
    file_path = $2

    module_name = file_path.split('/')[0..2].
      map do |value|
        value.
          split('_').
          map { |word| word[0].upcase + word[1..-1] }.
          join
      end.
      join('::')

    "{#{module_name}##{method_name} #{method_name}}"
  end
end
