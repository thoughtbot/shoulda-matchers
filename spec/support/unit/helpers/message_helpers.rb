module UnitTests
  module MessageHelpers
    include Shoulda::Matchers::WordWrap

    def self.configure_example_group(example_group)
      example_group.include(self)
    end

    def format_message(message, one_line: false)
      stripped_message = message.strip_heredoc.strip

      if one_line
        stripped_message.tr("\n", " ").squeeze(" ")
      else
        word_wrap(stripped_message)
      end
    end
  end
end
