module Shoulda # :nodoc:
  module Matchers
    module ActiveRecord # :nodoc:

      # Ensures the database column exists.
      #
      # Options:
      # * <tt>of_type</tt> - db column type (:integer, :string, etc.)
      # * <tt>with_options</tt> - same options available in migrations
      #   (:default, :null, :limit, :precision, :scale)
      #
      # Examples:
      #   it { should_not have_db_column(:admin).of_type(:boolean) }
      #   it { should have_db_column(:salary).
      #                 of_type(:decimal).
      #                 with_options(:precision => 10, :scale => 2) }
      #
      def have_db_column(column)
        HaveDbColumnMatcher.new(column)
      end

      class HaveDbColumnMatcher # :nodoc:
        def initialize(column)
          @column = column
          @options = {}
        end

        def of_type(column_type)
          @options[:column_type] = column_type
          self
        end

        def with_options(opts = {})
          %w(precision limit default null scale primary).each do |attribute|
            if opts.key?(attribute.to_sym)
              @options[attribute.to_sym] = opts[attribute.to_sym]
            end
          end
          self
        end

        def matches?(subject)
          @subject = subject
          column_exists? &&
            correct_column_type? &&
            correct_precision? &&
            correct_limit? &&
            correct_default? &&
            correct_null? &&
            correct_scale? &&
            correct_primary?
        end

        def failure_message_for_should
          "Expected #{expectation} (#{@missing})"
        end

        def failure_message_for_should_not
          "Did not expect #{expectation}"
        end

        def description
          desc = "have db column named #{@column}"
          desc << " of type #{@options[:column_type]}"    if @options.key?(:column_type)
          desc << " of precision #{@options[:precision]}" if @options.key?(:precision)
          desc << " of limit #{@options[:limit]}"         if @options.key?(:limit)
          desc << " of default #{@options[:default]}"     if @options.key?(:default)
          desc << " of null #{@options[:null]}"           if @options.key?(:null)
          desc << " of primary #{@options[:primary]}"     if @options.key?(:primary)
          desc << " of scale #{@options[:scale]}"         if @options.key?(:scale)
          desc
        end

        protected

        def column_exists?
          if model_class.column_names.include?(@column.to_s)
            true
          else
            @missing = "#{model_class} does not have a db column named #{@column}."
            false
          end
        end

        def correct_column_type?
          return true unless @options.key?(:column_type)

          if matched_column.type.to_s == @options[:column_type].to_s
            true
          else
            @missing = "#{model_class} has a db column named #{@column} " <<
                       "of type #{matched_column.type}, not #{@options[:column_type]}."
            false
          end
        end

        def correct_precision?
          return true unless @options.key?(:precision)

          if matched_column.precision.to_s == @options[:precision].to_s
            true
          else
            @missing = "#{model_class} has a db column named #{@column} " <<
                       "of precision #{matched_column.precision}, " <<
                       "not #{@options[:precision]}."
            false
          end
        end

        def correct_limit?
          return true unless @options.key?(:limit)

          if matched_column.limit.to_s == @options[:limit].to_s
            true
          else
            @missing = "#{model_class} has a db column named #{@column} " <<
                       "of limit #{matched_column.limit}, " <<
                       "not #{@options[:limit]}."
            false
          end
        end

        def correct_default?
          return true unless @options.key?(:default)

          if matched_column.default.to_s == @options[:default].to_s
            true
          else
            @missing = "#{model_class} has a db column named #{@column} " <<
                       "of default #{matched_column.default}, " <<
                       "not #{@options[:default]}."
            false
          end
        end

        def correct_null?
          return true unless @options.key?(:null)

          if matched_column.null.to_s == @options[:null].to_s
            true
          else
            @missing = "#{model_class} has a db column named #{@column} " <<
                       "of null #{matched_column.null}, " <<
                       "not #{@options[:null]}."
            false
          end
        end

        def correct_scale?
          return true unless @options.key?(:scale)

          if actual_scale.to_s == @options[:scale].to_s
            true
          else
            @missing = "#{model_class} has a db column named #{@column} "
            @missing << "of scale #{actual_scale}, not #{@options[:scale]}."
            false
          end
        end

        def correct_primary?
          return true unless @options.key?(:primary)

          if matched_column.primary == @options[:primary]
            true
          else
            @missing = "#{model_class} has a db column named #{@column} "
            if @options[:primary]
              @missing << 'that is not primary, but should be'
            else
              @missing << 'that is primary, but should not be'
            end
            false
          end
        end

        def matched_column
          model_class.columns.detect { |each| each.name == @column.to_s }
        end

        def model_class
          @subject.class
        end

        def actual_scale
          matched_column.scale
        end

        def expectation
          expected = "#{model_class.name} to #{description}"
        end
      end
    end
  end
end
