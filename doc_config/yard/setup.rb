YARD::Templates::Engine.register_template_path(
  "#{File.dirname(__FILE__)}/templates",
)

require 'rouge'

module YARD
  module Templates
    module Helpers
      module HtmlSyntaxHighlightHelper
        def html_syntax_highlight_ruby(source)
          highlight(:ruby, source)
        end

        private

        def highlight(language, source)
          lexer = Rouge::Lexers.const_get(language.capitalize)
          Rouge::Formatters::HTML.new.format(lexer.new.lex(source))
        end
      end
    end
  end
end
