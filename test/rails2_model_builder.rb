class ActiveSupport::TestCase

  TMP_VIEW_PATH =
    File.expand_path(File.join(File.dirname(__FILE__), 'rails2_root', 'tmp', 'views')).freeze

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

  def define_constant(class_name, base, &block)
    class_name = class_name.to_s.camelize

    klass = Class.new(base)
    Object.const_set(class_name, klass)

    klass.class_eval(&block) if block_given?

    @defined_constants ||= []
    @defined_constants << class_name

    klass
  end

  def define_model_class(class_name, &block)
    define_constant(class_name, ActiveRecord::Base, &block)
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

    paths.each {|path| create_view("#{name}/#{path}", "<%= @message %>")}
    klass.template_root = TMP_VIEW_PATH
  end

  def define_controller(class_name, &block)
    class_name = class_name.to_s
    class_name << 'Controller' unless class_name =~ /Controller$/
    define_constant(class_name, ActionController::Base, &block)
  end

  def define_routes(&block)
    @replaced_routes = ActionController::Routing::Routes
    new_routes = ActionController::Routing::RouteSet.new
    silence_warnings do
      ActionController::Routing.const_set('Routes', new_routes)
    end
    new_routes.draw(&block)
  end

  def build_response(opts = {}, &block)
    action = opts[:action] || 'example'
    klass = define_controller('Examples')
    block ||= lambda { render :nothing => true }
    klass.class_eval { define_method(action, &block) }
    define_routes do |map|
      map.connect 'examples', :controller => 'examples', :action => action
    end

    create_view("examples/#{action}.html.erb", "abc")
    klass.view_paths = [TMP_VIEW_PATH]

    @controller = klass.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    get action

    @controller
  end

  def create_view(path, contents)
    full_path = File.join(TMP_VIEW_PATH, path)
    FileUtils.mkdir_p(File.dirname(full_path))
    File.open(full_path, 'w') { |file| file.write(contents) }
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

    if @replaced_routes
      ActionController::Routing::Routes.clear!
      silence_warnings do
        ActionController::Routing.const_set('Routes', @replaced_routes)
      end
      @replaced_routes.reload!
    end

    FileUtils.rm_rf(TMP_VIEW_PATH)

    teardown_without_models
  end
  alias_method :teardown_without_models, :teardown
  alias_method :teardown, :teardown_with_models
end
