# These are gonna be added to the tb_test_helper plugin, so don't touch unless you know what you're doing.
class Test::Unit::TestCase
  
  class ResourceOptions
    class ActionOptions
      attr_accessor :redirect, :flash, :params, :render, :actions
    end

    attr_accessor :identifier, :klass, :object, :parent, 
                  :test_html_actions, :test_xml_actions, 
                  :create, :update, :destroy, :denied

    alias parents parent
    alias parents= parent=
    
    def initialize
      @create  = ActionOptions.new
      @update  = ActionOptions.new
      @destroy = ActionOptions.new
      @denied  = ActionOptions.new
      @test_html_actions = [:index, :show, :new, :edit, :create, :update, :destroy]
      @test_xml_actions  = [:index, :show, :create, :update, :destroy]
      @denied.actions    = []
    end
    
    def normalize!(target)
      @test_html_actions = @test_html_actions.map(&:to_sym)
      @test_xml_actions  = @test_xml_actions.map(&:to_sym)
      @denied.actions    = @denied.actions.map(&:to_sym)
      @identifier    ||= :id
      @klass         ||= target.name.gsub(/ControllerTest$/, '').singularize.constantize
      @object        ||= @klass.name.tableize.singularize
      @parent        ||= []
      @parent          = [@parent] unless @parent.is_a? Array
      
      singular_args = @parent.map {|n| "record.#{n}"}
      @destroy.redirect ||= "#{@object.pluralize}_url(#{singular_args.join(', ')})" 

      singular_args << 'record'
      @create.redirect  ||= "#{@object}_url(#{singular_args.join(', ')})"
      @update.redirect  ||= "#{@object}_url(#{singular_args.join(', ')})"
      @denied.redirect  ||= "new_session_url"
      
      @create.flash  ||= /created/i
      @update.flash  ||= /updated/i
      @destroy.flash ||= /removed/i
      @denied.flash  ||= /denied/i

      @create.params  ||= {}
      @update.params  ||= {}
    end
  end

  def self.should_be_restful(&blk)
    resource = ResourceOptions.new
    blk.call(resource)
    resource.normalize!(self)
    
    resource.test_html_actions.each do |action|
      self.send(:"make_#{action}_html_test", resource) if self.respond_to? :"make_#{action}_html_test"
    end

    context "XML: " do
      setup do
        @request.accept = "application/xml"
      end

      resource.test_xml_actions.each do |action|
        self.send(:"make_#{action}_xml_test", resource) if self.respond_to? :"make_#{action}_xml_test"
      end
    end
  end

  def self.make_show_html_test(res)
    # should "get show for @#{res.object} via params: #{pretty_param_string(res)}" do
    should "GET :show for @#{res.object}" do
      record = get_existing_record(res)
      parent_params = make_parent_params(res, record)
      get :show, parent_params.merge({ res.identifier => record.to_param })
      assert assigns(res.klass.name.underscore.to_sym), "The show action isn't assigning to @#{res.klass.name.underscore}"
      assert_response :success
      assert_template 'show'
      assert_equal({}, flash)
    end
  end

  def self.make_edit_html_test(res)
    # should "get edit for @#{res.object} via params: #{pretty_param_string(res)}" do
    should "GET :edit for @#{res.object}" do
      record = get_existing_record(res)
      parent_params = make_parent_params(res, record)
      get :edit, parent_params.merge({ res.identifier => record.to_param })
      assert assigns(res.klass.name.underscore.to_sym), "The edit action isn't assigning to @#{res.klass.name.underscore}"
      assert_response :success
      assert_select "form", true, "The edit template doesn't contain a <form> element"
      assert_template 'edit'
      assert_equal({}, flash)
    end
  end

  def self.make_index_html_test(res)
    should "GET :index" do
      parent_params = make_parent_params(res)
      get(:index, parent_params)
      assert_response :success
      assert assigns(res.klass.name.underscore.pluralize.to_sym), 
             "The index action isn't assigning to @#{res.klass.name.underscore.pluralize}"
      assert_template 'index'
      assert_equal({}, flash)
    end
  end

  def self.make_new_html_test(res)
    should "show form on GET to :new" do
      parent_params = make_parent_params(res)
      get(:new, parent_params)
      assert_response :success
      assert assigns(res.klass.name.underscore.to_sym), 
             "The new action isn't assigning to @#{res.klass.name.underscore}"
      assert_equal({}, flash)
      assert_template 'new'
    end
  end

  def self.make_destroy_html_test(res)
    should "destroy @#{res.object} on DELETE to :destroy" do
      record = get_existing_record(res)
      parent_params = make_parent_params(res, record)
      assert_difference(res.klass, :count, -1) do
        delete :destroy, parent_params.merge({ res.identifier => record.to_param })
        assert_redirected_to eval(res.destroy.redirect, self.send(:binding), __FILE__, __LINE__), 
                             "Flash: #{flash.inspect}"
        assert_contains flash.values, res.destroy.flash, ", Flash: #{flash.inspect}"
      end
    end
  end
  
  def self.make_create_html_test(res)
    should "create #{res.klass} record on POST to :create" do
      assert_difference(res.klass, :count, 1) do
        # params = res.parent_params.merge(res.object => res.create.params)
        parent_params = make_parent_params(res)
        post :create, parent_params.merge(res.object => res.create.params)
        assert record = assigns(res.object), "@#{res.object} not set after create"
        assert_equal [], record.errors.full_messages, "@#{res.object} has errors:"
        assert_redirected_to eval(res.create.redirect, self.send(:binding), __FILE__, __LINE__)
        assert_contains flash.values, res.create.flash, ", Flash: #{flash.inspect}"
      end      
    end
  end

  def self.make_update_html_test(res)
    should "update #{res.klass} record on PUT to :update" do
      record = get_existing_record(res)
      parent_params = make_parent_params(res, record)
      put :update, parent_params.merge(res.identifier => record.to_param, res.object => res.update.params)
      assert record = assigns(res.object), "@#{res.object} not set after create"
      assert_equal [], record.errors.full_messages, "@#{res.object} has errors:"
      assert_redirected_to eval(res.update.redirect, self.send(:binding), __FILE__, __LINE__)
      assert_contains flash.values, res.update.flash, ", Flash: #{flash.inspect}"
      res.update.params.each do |key, value|
        assert_equal value.to_s, record.send(key.to_sym).to_s, 
                     "#{res.object}.#{key} not set to #{value} after update"
      end
    end
  end
  
  def self.make_denied_update_test(res)
  end

  def self.make_show_xml_test(res)
    should "get show for @#{res.object} as xml" do
      record        = get_existing_record(res)
      parent_params = make_parent_params(res, record)

      get :show, parent_params.merge({ res.identifier => record.to_param }), :format => :xml      

      assert_equal "application/xml; charset=utf-8", @response.headers['Content-Type']
      assert_response :success
      assert_select "#{res.klass.name.underscore.dasherize}", 1, 
                    "Can't find <#{res.klass.name.underscore.dasherize.pluralize}> in \n#{@response.body}"
    end
  end

  def self.make_index_xml_test(res)
    should "get index as xml" do
      parent_params = make_parent_params(res)
      
      get(:index, parent_params)
      
      assert_equal "application/xml; charset=utf-8", @response.headers['Content-Type']
      assert_response :success
      assert_select "#{res.klass.name.underscore.dasherize.pluralize}", 1, 
                    "Can't find <#{res.klass.name.underscore.dasherize.pluralize}> in \n#{@response.body}"
    end
  end

  def self.make_destroy_xml_test(res)
    should "destroy @#{res.object} on 'delete' to destroy action as xml" do
      record = get_existing_record(res)
      parent_params = make_parent_params(res, record)

      assert_difference(res.klass, :count, -1) do
        delete :destroy, parent_params.merge({ res.identifier => record.to_param })
        assert_equal "application/xml; charset=utf-8", @response.headers['Content-Type']
        assert_response :success
        assert_match(/^\s*$/, @response.body, "The response body was not empty:")
      end
    end
  end  

  def self.make_create_xml_test(res)
    should "create #{res.klass} record on post to 'create' as xml" do
      assert_difference(res.klass, :count, 1) do
        # params = res.parent_params.merge(res.object => res.create.params)
        parent_params = make_parent_params(res)

        post :create, parent_params.merge(res.object => res.create.params)

        assert_equal "application/xml; charset=utf-8", @response.headers['Content-Type']
        assert_response :created
        assert record = assigns(res.object), "@#{res.object} not set after create"
        assert_equal [], record.errors.full_messages, "@#{res.object} has errors:"
        assert_equal eval(res.create.redirect, self.send(:binding), __FILE__, __LINE__),
                     @response.headers["Location"]
      end      
    end
  end

  def self.make_update_xml_test(res)
    should "update #{res.klass} record on put to :update as xml" do
      record = get_existing_record(res)
      parent_params = make_parent_params(res, record)

      put :update, parent_params.merge(res.identifier => record.to_param, res.object => res.update.params)

      assert_equal "application/xml; charset=utf-8", @response.headers['Content-Type']
      assert record = assigns(res.object), "@#{res.object} not set after create"
      assert_equal [], record.errors.full_messages, "@#{res.object} has errors:"
      assert_response :success
      assert_match(/^\s*$/, @response.body, "The response body was not empty:")
      res.update.params.each do |key, value|
        assert_equal value.to_s, record.send(key.to_sym).to_s,
                     "#{res.object}.#{key} not set to #{value} after update"
      end
    end
  end

  class << self
    private
    include ThoughtBot::Shoulda::Private
  end
  
  private

  def get_existing_record(res)
    returning(instance_variable_get "@#{res.object}") do |record|
      assert(record, "This test requires you to set @#{res.object} in your setup block")    
    end
  end

  def make_parent_params(resource, record = nil, parent_names = nil)
    parent_names ||= resource.parents.reverse
    
    return {} if parent_names == [] # Base case
    
    parent_name = parent_names.shift

    parent = record ? record.send(parent_name) : parent_name.to_s.classify.constantize.find(:first)
    
    { :"#{parent_name}_id" => parent.id }.merge(make_parent_params(resource, parent, parent_names))
  end
end
