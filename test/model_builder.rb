class DatabaseColumn
  attr_accessor :name, :type, :opts
  
  def initialize(name, type, opts = {})
    @name = name
    @type = type
    @opts = opts
  end
end

class Test::Unit::TestCase  
  def build_model_class(name, *columns, &block)
    class_name = name.to_s.pluralize.classify
    table_name = class_name.tableize
    connection = ActiveRecord::Base.connection
    
    begin
      connection.execute("DROP TABLE IF EXISTS #{table_name}")
      connection.create_table table_name do |t|
        columns.each do |column|
          if column.opts
            t.column column.name, column.type, column.opts
          else
            t.column column.name, column.type
          end
        end
      end
    rescue Exception => e
      connection.execute("DROP TABLE #{table_name}")
      raise e
    end

    klass = Class.new(ActiveRecord::Base)
    Object.const_set(class_name, klass)

    klass.class_eval(&block) if block_given?

    @built_models ||= []
    @built_models << klass

    klass
  end

  def teardown_with_models
    if @built_models
      @built_models.each do |klass| 
        ActiveRecord::Base.connection.execute("DROP TABLE #{klass.table_name}")
        Object.send(:remove_const, klass.name)
      end
    end
    teardown_without_models
  end
  alias_method :teardown_without_models, :teardown
  alias_method :teardown, :teardown_with_models
end
