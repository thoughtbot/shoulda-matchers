module Shoulda # :nodoc:
  module Matchers
    module ActiveRecord # :nodoc:

      # Ensures that the number of database queries is known. Rails 3.1 or greater is required.
      #
      # Options:
      # * <tt>when_calling</tt> - Required, the name of the method to examine.
      # * <tt>with</tt> - Used in conjunction with <tt>when_calling</tt> to pass parameters to the method to examine.
      # * <tt>or_less</tt> - Pass if the database is queried no more than the number of times specified, as opposed to exactly that number of times.
      #
      # Examples:
      #   it { should query_the_database(4.times).when_calling(:complicated_counting_method)
      #   it { should query_the_database(4.times).or_less.when_calling(:generate_big_report)
      #   it { should_not query_the_database.when_calling(:cached_count)
      #
      def query_the_database(times = nil)
        QueryTheDatabaseMatcher.new(times)
      end

      class QueryTheDatabaseMatcher # :nodoc:
        def initialize(times)
          if times.respond_to?(:count)
            @expected_query_count = times.count
          else
            @expected_query_count = times
          end
        end

        def when_calling(method_name)
          @method_name = method_name
          self
        end

        def with(*method_arguments)
          @method_arguments = method_arguments
          self
        end

        def or_less
          @expected_count_is_maximum = true
          self
        end

        def matches?(subject)
          @queries = []

          subscriber = ActiveSupport::Notifications.subscribe('sql.active_record') do |name, started, finished, id, payload|
            @queries << payload unless filter_query(payload)
          end

          if @method_arguments
            subject.send(@method_name, *@method_arguments)
          else
            subject.send(@method_name)
          end

          ActiveSupport::Notifications.unsubscribe(subscriber)

          if @expected_count_is_maximum
            @queries.length <= @expected_query_count
          elsif @expected_query_count.present?
            @queries.length == @expected_query_count
          else
            @queries.length > 0
          end
        end

        def failure_message
          if @expected_query_count
            "Expected ##{@method_name} to cause #{@expected_query_count} database queries but it actually caused #{@queries.length} queries:" + friendly_queries
          else
            "Expected ##{@method_name} to query the database but it actually caused #{@queries.length} queries:" + friendly_queries
          end
        end

        def negative_failure_message
          if @expected_query_count
            "Expected ##{@method_name} to not cause #{@expected_query_count} database queries but it actually caused #{@queries.length} queries:" + friendly_queries
          else
            "Expected ##{@method_name} to not query the database but it actually caused #{@queries.length} queries:" + friendly_queries
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
