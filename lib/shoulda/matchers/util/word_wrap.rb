module Shoulda
  module Matchers
    # @private
    def self.word_wrap(document)
      Document.new(document).wrap
    end

    # @private
    class Document
      def initialize(document)
        @document = document
      end

      def wrap
        wrapped_paragraphs.map { |lines| lines.join("\n") }.join("\n\n")
      end

      protected

      attr_reader :document

      private

      def paragraphs
        document.split(/\n{2,}/)
      end

      def wrapped_paragraphs
        paragraphs.map do |paragraph|
          Paragraph.new(paragraph).wrap
        end
      end
    end

    # @private
    class Text < ::String
      LIST_ITEM_REGEXP = /\A((?:[a-z0-9]+(?:\)|\.)|\*) )/

      def indented?
        self =~ /\A[ ]+/
      end

      def list_item?
        self =~ LIST_ITEM_REGEXP
      end

      def match_as_list_item
        match(LIST_ITEM_REGEXP)
      end
    end

    # @private
    class Paragraph
      def initialize(paragraph)
        @paragraph = Text.new(paragraph)
      end

      def wrap
        if paragraph.indented?
          lines
        elsif paragraph.list_item?
          wrap_list_item
        else
          wrap_generic_paragraph
        end
      end

      protected

      attr_reader :paragraph

      private

      def wrap_list_item
        wrap_lines(combine_list_item_lines(lines))
      end

      def lines
        paragraph.split("\n").map { |line| Text.new(line) }
      end

      def combine_list_item_lines(lines)
        lines.reduce([]) do |combined_lines, line|
          if line.list_item?
            combined_lines << line
          else
            combined_lines.last << (' ' + line).squeeze(' ')
          end

          combined_lines
        end
      end

      def wrap_lines(lines)
        lines.map { |line| Line.new(line).wrap }
      end

      def wrap_generic_paragraph
        Line.new(combine_paragraph_into_one_line).wrap
      end

      def combine_paragraph_into_one_line
        paragraph.gsub(/\n/, ' ')
      end
    end

    # @private
    class Line
      TERMINAL_WIDTH = 72

      def initialize(line)
        @original_line = @line_to_wrap = Text.new(line)
        @indentation = nil
      end

      def wrap
        lines = []

        if line_to_wrap.indented?
          lines << line_to_wrap
        else
          loop do
            new_line = (indentation || '') + line_to_wrap
            result = wrap_line(new_line)
            lines << result[:fitted_line].rstrip
            @indentation ||= read_indentation
            @line_to_wrap = result[:leftover]

            if line_to_wrap.empty? || @original_line == @line_to_wrap
              break
            end
          end
        end

        lines
      end

      protected

      attr_reader :original_line, :line_to_wrap, :indentation

      private

      def read_indentation
        match = line_to_wrap.match_as_list_item

        if match
          ' ' * match[1].length
        else
          ''
        end
      end

      def wrap_line(line)
        if line.length > TERMINAL_WIDTH
          index = determine_where_to_break_line(line)
          fitted_line = line[0 .. index].rstrip
          leftover = line[index + 1 .. -1]
        else
          fitted_line = line
          leftover = ''
        end

        { fitted_line: fitted_line, leftover: leftover }
      end

      def determine_where_to_break_line(line)
        index = TERMINAL_WIDTH - 1

        while line[index] !~ /\s/
          index -= 1
        end

        index
      end
    end
  end
end
