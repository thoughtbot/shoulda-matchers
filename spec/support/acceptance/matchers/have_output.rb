module AcceptanceTests
  module Matchers
    def have_output(output)
      HaveOutputMatcher.new(output)
    end

    class HaveOutputMatcher
      def initialize(output)
        @output = output
      end

      def matches?(runner)
        @runner = runner
        runner.has_output?(output)
      end

      def failure_message
        "Expected command to have output, but did not.\n\n" +
          "Command: #{runner.formatted_command}\n\n" +
          "Expected output:\n" +
          output + "\n\n" +
          "Actual output:\n" +
          runner.elided_output
      end

      protected

      attr_reader :output, :runner
    end
  end
end
