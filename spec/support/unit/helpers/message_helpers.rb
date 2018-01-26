module UnitTests
  module MessageHelpers
    include Shoulda::Matchers::WordWrap

    def self.configure_example_group(example_group)
      example_group.include(self)
    end

    def format_message(message)
      word_wrap(message.strip_heredoc.strip)
    end
  end
end
