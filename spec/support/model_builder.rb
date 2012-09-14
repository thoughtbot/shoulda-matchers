module ModelBuilder
  def self.included(example_group)
    example_group.class_eval do
      before do
        @created_tables ||= []
      end

      after do
        drop_created_tables
      end
    end
  end

  def create_table(table_name, options = {}, &block)
    connection = ActiveRecord::Base.connection

    begin
      connection.execute("DROP TABLE IF EXISTS #{table_name}")
      connection.create_table(table_name, options, &block)
      @created_tables << table_name
      connection
    rescue Exception => e
      connection.execute("DROP TABLE IF EXISTS #{table_name}")
      raise e
    end
  end

  def define_model_class(class_name, &block)
    define_class(class_name, ActiveRecord::Base, &block)
  end

  def define_active_model_class(class_name, options = {}, &block)
    define_class(class_name) do
      include ActiveModel::Validations
      extend ActiveModel::Callbacks
      define_model_callbacks :initialize, :find, :touch, :only => :after
      define_model_callbacks :save, :create, :update, :destroy
      
      options[:accessors].each do |column|
        attr_accessor column.to_sym
      end

      if block_given?
        class_eval(&block)
      end
    end
  end

  def define_model(name, columns = {}, &block)
    class_name = name.to_s.pluralize.classify
    table_name = class_name.tableize

    create_table(table_name) do |table|
      columns.each do |name, type|
        table.column name, type
      end
    end

    define_model_class(class_name, &block)
  end

  def drop_created_tables
    connection = ActiveRecord::Base.connection

    @created_tables.each do |table_name|
      connection.execute("DROP TABLE IF EXISTS #{table_name}")
    end
  end
end

RSpec.configure do |config|
  config.include ModelBuilder
end
