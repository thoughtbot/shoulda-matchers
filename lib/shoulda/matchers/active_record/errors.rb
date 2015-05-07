module Shoulda
  module Matchers
    module ActiveRecord
      class Error < StandardError
        def initialize(original_exception)
          message = <<-EOT.strip_heredoc
            Check your models definitions, the following error was raised by ActiveRecord:
            #{original_exception.inspect}
          EOT
          super(message)
        end
      end
    end
  end
end
