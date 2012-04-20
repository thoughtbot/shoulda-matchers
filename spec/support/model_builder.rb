module ModelBuilder
  TMP_VIEW_PATH =
    File.expand_path(File.join(TESTAPP_ROOT, 'tmp', 'views')).freeze

  def self.included(example_group)
    example_group.class_eval do
      before do
        @created_tables ||= []
      end

      after do
        teardown_defined_constants
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

  def define_class(class_name, base = Object, &block)
    class_name = class_name.to_s.camelize

    Class.new(base).tap do |constant_class|
      Object.const_set(class_name, constant_class)
      constant_class.unloadable

      if block_given?
        constant_class.class_eval(&block)
      end

      if constant_class.respond_to?(:reset_column_information)
        constant_class.reset_column_information
      end
    end
  end

  def define_model_class(class_name, &block)
    define_class(class_name, ActiveRecord::Base, &block)
  end

  def define_active_model_class(class_name, options = {}, &block)
    define_class(class_name, Object) do
      include ActiveModel::Validations

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

  def define_mailer(name, paths, &block)
    class_name = name.to_s.pluralize.classify
    define_class(class_name, ActionMailer::Base, &block)
  end

  def define_controller(class_name, &block)
    class_name = class_name.to_s
    class_name << 'Controller' unless class_name =~ /Controller$/
    define_class(class_name, ActionController::Base, &block)
  end

  def define_routes(&block)
    Rails.application.routes.draw(&block)
    @routes = Rails.application.routes
    class << self
      include ActionDispatch::Assertions
    end
  end

  def build_response(opts = {}, &block)
    action = opts[:action] || 'example'
    partial = opts[:partial] || '_partial'
    klass = define_controller('Examples')
    block ||= lambda { render :nothing => true }
    klass.class_eval { layout false; define_method(action, &block) }
    define_routes do
      match 'examples', :to => "examples##{action}"
    end

    create_view("examples/#{action}.html.erb", "abc")
    create_view("examples/#{partial}.html.erb", "partial")
    klass.view_paths = [TMP_VIEW_PATH]

    @controller = klass.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    class << self
      include ActionController::TestCase::Behavior
    end
    @routes = Rails.application.routes

    get action

    @controller
  end

  def create_view(path, contents)
    full_path = File.join(TMP_VIEW_PATH, path)
    FileUtils.mkdir_p(File.dirname(full_path))
    File.open(full_path, 'w') { |file| file.write(contents) }
  end

  def teardown_defined_constants
    ActiveSupport::Dependencies.clear

    connection = ActiveRecord::Base.connection

    @created_tables.each do |table_name|
      connection.execute("DROP TABLE IF EXISTS #{table_name}")
    end

    FileUtils.rm_rf(TMP_VIEW_PATH)

    Rails.application.reload_routes!
  end
end

RSpec.configure do |config|
  config.include ModelBuilder
end
