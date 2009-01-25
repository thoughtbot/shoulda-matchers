class Test::Unit::TestCase  
  def create_table(table_name, &block)
    connection = ActiveRecord::Base.connection
    
    begin
      connection.execute("DROP TABLE IF EXISTS #{table_name}")
      connection.create_table(table_name, &block)
      @created_tables ||= []
      @created_tables << table_name
      connection
    rescue Exception => e
      connection.execute("DROP TABLE IF EXISTS #{table_name}")
      raise e
    end
  end

  def define_model_class(class_name, &block)
    klass = Class.new(ActiveRecord::Base)
    Object.const_set(class_name, klass)

    klass.class_eval(&block) if block_given?

    @defined_constants ||= []
    @defined_constants << class_name

    klass
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

  def teardown_with_models
    if @defined_constants
      @defined_constants.each do |class_name| 
        Object.send(:remove_const, class_name)
      end
    end

    if @created_tables
      @created_tables.each do |table_name|
        ActiveRecord::Base.
          connection.
          execute("DROP TABLE IF EXISTS #{table_name}")
      end
    end

    teardown_without_models
  end
  alias_method :teardown_without_models, :teardown
  alias_method :teardown, :teardown_with_models
end
