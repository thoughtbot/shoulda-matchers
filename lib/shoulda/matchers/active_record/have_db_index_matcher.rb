module Shoulda
  module Matchers
    module ActiveRecord
      # The `have_db_index` matcher tests that the table that backs your model
      # has a index on a specific column.
      #
      #     class CreateBlogs < ActiveRecord::Migration
      #       def change
      #         create_table :blogs do |t|
      #           t.integer :user_id
      #         end
      #
      #         add_index :blogs, :user_id
      #       end
      #     end
      #
      #     # RSpec
      #     RSpec.describe Blog, type: :model do
      #       it { should have_db_index(:user_id) }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class BlogTest < ActiveSupport::TestCase
      #       should have_db_index(:user_id)
      #     end
      #
      # #### Qualifiers
      #
      # ##### unique
      #
      # Use `unique` to assert that the index is unique.
      #
      #     class CreateBlogs < ActiveRecord::Migration
      #       def change
      #         create_table :blogs do |t|
      #           t.string :name
      #         end
      #
      #         add_index :blogs, :name, unique: true
      #       end
      #     end
      #
      #     # RSpec
      #     RSpec.describe Blog, type: :model do
      #       it { should have_db_index(:name).unique(true) }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class BlogTest < ActiveSupport::TestCase
      #       should have_db_index(:name).unique(true)
      #     end
      #
      # Since it only ever makes since for `unique` to be `true`, you can also
      # leave off the argument to save some keystrokes:
      #
      #     # RSpec
      #     RSpec.describe Blog, type: :model do
      #       it { should have_db_index(:name).unique }
      #     end
      #
      #     # Minitest (Shoulda)
      #     class BlogTest < ActiveSupport::TestCase
      #       should have_db_index(:name).unique
      #     end
      #
      # @return [HaveDbIndexMatcher]
      #
      def have_db_index(columns)
        HaveDbIndexMatcher.new(columns)
      end

      # @private
      class HaveDbIndexMatcher
        def initialize(columns)
          @columns = normalize_columns_to_array(columns)
          @options = {}
        end

        def unique(unique = true)
          @options[:unique] = unique
          self
        end

        def matches?(subject)
          @subject = subject
          index_exists? && correct_unique?
        end

        def failure_message
          "Expected #{expectation} (#{@missing})"
        end

        def failure_message_when_negated
          "Did not expect #{expectation}"
        end

        def description
          if @options.key?(:unique)
            "have a #{index_type} index on columns #{@columns.join(' and ')}"
          else
            "have an index on columns #{@columns.join(' and ')}"
          end
        end

        protected

        def index_exists?
          ! matched_index.nil?
        end

        def correct_unique?
          return true unless @options.key?(:unique)

          is_unique = matched_index.unique

          is_unique = !is_unique unless @options[:unique]

          unless is_unique
            @missing = "#{table_name} has an index named #{matched_index.name} " <<
            "of unique #{matched_index.unique}, not #{@options[:unique]}."
          end

          is_unique
        end

        def matched_index
          indexes.detect { |each| each.columns == @columns }
        end

        def model_class
          @subject.class
        end

        def table_name
          model_class.table_name
        end

        def indexes
          ::ActiveRecord::Base.connection.indexes(table_name)
        end

        def expectation
          "#{model_class.name} to #{description}"
        end

        def index_type
          if @options[:unique]
            'unique'
          else
            'non-unique'
          end
        end

        def normalize_columns_to_array(columns)
          Array.wrap(columns).map(&:to_s)
        end
      end
    end
  end
end
