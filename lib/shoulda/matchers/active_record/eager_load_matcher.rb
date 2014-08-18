require 'logger'

module Shoulda
  module Matchers
    module ActiveRecord
      def eager_load(&data_creator)
        EagerLoadMatcher.new(data_creator)
      end

      class EagerLoadMatcher
        def initialize(data_creator)
          @data_creator = data_creator
        end

        def matches?(eager_loaded_block)
          @eager_loaded_block = eager_loaded_block

          @output = 3.times.map do
            @data_creator.call
            trace_queries { @eager_loaded_block.call }
          end

          @output.second.size == @output.third.size
        end

        def failure_message
          "Expected a constant number of queries, but got queries:\n" +
            @output.third.join("\n")
        end

        def trace_queries(&block)
          output = StringIO.new
          logger = Logger.new(output)
          with_logger(logger, &block)
          output.rewind
          output.read.split("\n")
        end

        def with_logger(logger)
          old_logger = ::ActiveRecord::Base.logger
          ::ActiveRecord::Base.logger = logger
          yield
        ensure
          ::ActiveRecord::Base.logger = old_logger
        end
      end
    end
  end
end
