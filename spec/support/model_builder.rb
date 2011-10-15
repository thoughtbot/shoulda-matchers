module ModelBuilder
  TMP_VIEW_PATH =
    File.expand_path(File.join(TESTAPP_ROOT, 'tmp', 'views')).freeze

  def self.included(example_group)
    example_group.class_eval do
      before do
        @created_tables ||= []
      end

      after { teardown_defined_constants }
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

  def define_constant(class_name, base, &block)
    class_name = class_name.to_s.camelize

    klass = Class.new(base)
    Object.const_set(class_name, klass)
    klass.unloadable

    klass.class_eval(&block) if block_given?
    klass.reset_column_information if klass.respond_to?(:reset_column_information)

    klass
  end

  def define_model_class(class_name, &block)
    define_constant(class_name, ActiveRecord::Base, &block)
  end

  def define_active_model_class(class_name, options = {}, &block)
    define_constant(class_name, Object) do
      include ActiveModel::Validations

      options[:accessors].each do |column|
        attr_accessor column.to_sym
      end

      class_eval(&block) if block_given?
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
    klass = define_constant(class_name, ActionMailer::Base, &block)
  end

  def define_controller(class_name, &block)
    class_name = class_name.to_s
    class_name << 'Controller' unless class_name =~ /Controller$/
    define_constant(class_name, ActionController::Base, &block)
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
    @controller.send :assign_shortcuts, @request, @response
    @controller.send :initialize_template_class, @response

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

    @created_tables.each do |table_name|
      ActiveRecord::Base.
        connection.
        execute("DROP TABLE IF EXISTS #{table_name}")
    end

    FileUtils.rm_rf(TMP_VIEW_PATH)

    Rails.application.reload_routes!
  end
end

RSpec.configure do |config|
  config.include ModelBuilder
end

