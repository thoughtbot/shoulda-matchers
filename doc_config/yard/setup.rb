YARD::Templates::Engine.register_template_path(File.dirname(__FILE__) + '/templates')

require 'pygments.rb'

module YARD
  module Templates
    module Helpers
      module HtmlSyntaxHighlightHelper
        def html_syntax_highlight_ruby(source)
          highlight_with_pygments(:ruby, source)
        end

        private

        def highlight_with_pygments(language, source)
          html = Pygments.highlight(source, lexer: language.to_s)
          html.sub(%r{\A<div class="highlight">\s*<pre>}, '').sub(%r{</pre>\s*</div>\Z}, '')
        end
      end
    end
  end
end
