# These are gonna be added to the tb_test_helper plugin, so don't touch unless you know what you're doing.
class Test::Unit::TestCase
  
  class ResourceOptions
    class ActionOptions
      attr_accessor :redirect, :flash, :params, :render
    end

    attr_accessor :identifier, :klass, :object, :parent_params, :test_actions, 
                  :create, :update, :destroy
    
    def initialize
      @create  = ActionOptions.new
      @update  = ActionOptions.new
      @destroy = ActionOptions.new
      @test_actions = [:index, :show, :new, :edit, :create, :update, :destroy]
    end
    
    def normalize!(target)
      @test_actions = @test_actions.map(&:to_sym)
      @identifier    ||= :id
      @klass         ||= target.name.gsub(/ControllerTest$/, '').singularize.constantize
      @object        ||= @klass.name.tableize.singularize
      @parent_params ||= {}
      
      @create.redirect  ||= "#{@object}_url(record)"
      @update.redirect  ||= "#{@object}_url(record)"
      @destroy.redirect ||= "#{@object.pluralize}_url"
      
      @create.flash  ||= /created/i
      @update.flash  ||= /updated/i
      @destroy.flash ||= /removed/i

      @create.params  ||= {}
      @update.params  ||= {}
    end
  end

  def self.should_be_a_resource(&blk)
    resource = ResourceOptions.new
    blk.call(resource)
    resource.normalize!(self)
    
    make_show_test(resource)    if resource.test_actions.include?(:show)
    make_edit_test(resource)    if resource.test_actions.include?(:edit)
    make_index_test(resource)   if resource.test_actions.include?(:index)
    make_new_test(resource)     if resource.test_actions.include?(:new)
    make_destroy_test(resource) if resource.test_actions.include?(:destroy)
    make_create_test(resource)  if resource.test_actions.include?(:create)
    make_update_test(resource)  if resource.test_actions.include?(:update)
  end

  def self.make_show_test(res)
    should "get show for @#{res.object} via params: #{pretty_param_string(res)}" do
      assert(record = instance_variable_get("@#{res.object}"), "This test requires you to set @#{res.object} in your setup block")
      get :show, res.parent_params.merge({ res.identifier => record.to_param })
      assert assigns(res.klass.name.underscore.to_sym), "The show action isn't assigning to @#{res.klass.name.underscore}"
      assert_response :success
      assert_template 'show'
      assert_equal({}, flash)
    end
  end

  def self.make_edit_test(res)
    should "get edit for @#{res.object} via params: #{pretty_param_string(res)}" do
      assert(record = instance_variable_get("@#{res.object}"), "This test requires you to set @#{res.object} in your setup block")
      get :edit, res.parent_params.merge({ res.identifier => record.to_param })
      assert assigns(res.klass.name.underscore.to_sym), "The edit action isn't assigning to @#{res.klass.name.underscore}"
      assert_response :success
      assert_select "form", true, "The edit template doesn't contain a <form> element"
      assert_template 'edit'
      assert_equal({}, flash)
    end
  end

  def self.make_index_test(res)
    should "get index" do
      get(:index, res.parent_params)
      assert_response :success
      assert assigns(res.klass.name.underscore.pluralize.to_sym), 
             "The index action isn't assigning to @#{res.klass.name.underscore.pluralize}"
      assert_template 'index'
      assert_equal({}, flash)
    end
  end

  def self.make_new_test(res)
    should "show form on get to new" do
      get(:new, res.parent_params)
      assert_response :success
      assert assigns(res.klass.name.underscore.to_sym), 
             "The new action isn't assigning to @#{res.klass.name.underscore}"
      assert_equal({}, flash)
      assert_template 'new'
    end
  end

  def self.make_destroy_test(res)
    should "destroy @#{res.object} on 'delete' to destroy action" do
      assert(record = instance_variable_get("@#{res.object}"), 
             "This test requires you to set @#{res.object} in your setup block")
      assert_difference(res.klass, :count, -1) do
        delete :destroy, res.parent_params.merge({ res.identifier => record.to_param })
        assert_redirected_to eval(res.destroy.redirect, self.send(:binding), __FILE__, __LINE__), 
                             "Flash: #{flash.inspect}"
        assert_contains flash.values, res.destroy.flash, ", Flash: #{flash.inspect}"
      end
    end
  end
  
  def self.make_create_test(res)
    should "create #{res.klass} record on post to 'create'" do
      assert_difference(res.klass, :count, 1) do
        post :create, res.parent_params.merge(res.object => res.create.params)
        assert record = assigns(res.object), "@#{res.object} not set after create"
        assert_equal [], record.errors.full_messages, "@#{res.object} has errors:"
        assert_redirected_to eval(res.create.redirect, self.send(:binding), __FILE__, __LINE__)
        assert_contains flash.values, res.create.flash, ", Flash: #{flash.inspect}"
      end      
    end
  end

  def self.make_update_test(res)
    should "update #{res.klass} record on put to :update" do
      assert(record = instance_variable_get("@#{res.object}"), 
             "This test requires you to set @#{res.object} in your setup block")
      put :update, res.parent_params.merge(res.identifier => record.to_param, res.object => res.create.params)
      assert record = assigns(res.object), "@#{res.object} not set after create"
      assert_equal [], record.errors.full_messages, "@#{res.object} has errors:"
      assert_redirected_to eval(res.update.redirect, self.send(:binding), __FILE__, __LINE__)
      assert_contains flash.values, res.update.flash, ", Flash: #{flash.inspect}"
      res.create.params.each do |key, value|
        assert_equal value.to_s, record.send(key.to_sym).to_s, 
                     "#{res.object}.#{key} not set to #{value} after update"
      end
    end
  end
  
  def self.should_be_denied_on(method, action, opts ={})
    redirect_proc  = opts[:redirect]
    klass          = opts[:klass]        || self.name.gsub(/ControllerTest/, '').singularize.constantize
    params         = opts[:params]       || {}
    expected_flash = opts[:flash]        || /\w+/
    
    should "no be able to #{method.to_s.upcase} #{action}" do
      assert_no_difference(klass, :count) do
        self.send(method, action, params)
        assert_contains flash.values, expected_flash
        
        assert_response :redirect
        if redirect_proc
          assert_redirected_to(@controller.instance_eval(&redirect_proc))
        end
      end
    end
  end
    
  class << self
    private  
    include ThoughtBot::Shoulda::Private
  end
  
  private

  def self.pretty_param_string(res)
    res.parent_params.merge({ res.identifier => :X }).inspect.gsub(':X', '@object.to_param').gsub('=>', ' => ')
  end
  
end
