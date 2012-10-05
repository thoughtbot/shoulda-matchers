module Shoulda # :nodoc:
  module Matchers
    module ActiveRecord # :nodoc:

      # DEPRECATED - This matcher will be removed in ShouldaMatchers 2.0, please remove all references to it.
      def query_the_database(times = nil)
        QueryTheDatabaseMatcher.new(times)
      end

      class QueryTheDatabaseMatcher # :nodoc:
        def initialize(times)
          ActiveSupport::Deprecation.warn("'query_the_database' will be removed in ShouldaMatchers 2.0.")
          @queries = []
          @options = {}

          if times.respond_to?(:count)
            @options[:expected_query_count] = times.count
          else
            @options[:expected_query_count] = times
          end
        end

        def when_calling(method_name)
          @options[:method_name] = method_name
          self
        end

        def with(*method_arguments)
          @options[:method_arguments] = method_arguments
          self
        end

        def or_less
          @options[:expected_count_is_maximum] = true
          self
        end

        def matches?(subject)
          subscriber = ActiveSupport::Notifications.subscribe('sql.active_record') do |name, started, finished, id, payload|
            @queries << payload unless filter_query(payload)
          end

          if @options[:method_arguments]
            subject.send(@options[:method_name], *@options[:method_arguments])
          else
            subject.send(@options[:method_name])
          end

          ActiveSupport::Notifications.unsubscribe(subscriber)

          if @options[:expected_count_is_maximum]
            @queries.length <= @options[:expected_query_count]
          elsif @options[:expected_query_count].present?
            @queries.length == @options[:expected_query_count]
          else
            @queries.length > 0
          end
        end

        def failure_message
          if @options.key?(:expected_query_count)
            "Expected ##{@options[:method_name]} to cause #{@options[:expected_query_count]} database queries but it actually caused #{@queries.length} queries:" + friendly_queries
          else
            "Expected ##{@options[:method_name]} to query the database but it actually caused #{@queries.length} queries:" + friendly_queries
          end
        end

        def negative_failure_message
          if @options[:expected_query_count]
            "Expected ##{@options[:method_name]} to not cause #{@options[:expected_query_count]} database queries but it actually caused #{@queries.length} queries:" + friendly_queries
          else
            "Expected ##{@options[:method_name]} to not query the database but it actually caused #{@queries.length} queries:" + friendly_queries
          end
        end

        private

        def friendly_queries
          @queries.map do |query|
            "\n  (#{query[:name]}) #{query[:sql]}"
          end.join
        end

        def filter_query(query)
          query[:name] == 'SCHEMA' || looks_like_schema?(query[:sql])
        end

        def schema_terms
          ['FROM sqlite_master', 'PRAGMA', 'SHOW TABLES', 'SHOW KEYS FROM', 'SHOW FIELDS FROM', 'begin transaction', 'commit transaction']
        end

        def looks_like_schema?(sql)
          schema_terms.any? { |term| sql.include?(term) }
        end
      end
    end
  end
end
