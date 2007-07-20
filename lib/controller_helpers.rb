# These are gonna be added to the tb_test_helper plugin, so don't touch unless you know what you're doing.
module ThoughtBot::Shoulda::HtmlTests
  def self.included(other)
    other.class_eval do
      extend ThoughtBot::Shoulda::HtmlTests::ClassMethods
    end
  end
  
  module ClassMethods
    def make_show_html_tests(res)
      context "on GET to :show" do
        setup do
          record = get_existing_record(res)
          parent_params = make_parent_params(res, record)
          get :show, parent_params.merge({ res.identifier => record.to_param })          
        end

        if res.denied.actions.include?(:show)
          should_not_assign_to res.object
          should_deny_html_request(res)
        else
          should_assign_to res.object          
          should_respond_with :success
          should_render_template :show
          should_not_set_the_flash
        end
      end
    end

    def make_edit_html_tests(res)
      context "on GET to :edit" do
        setup do
          @record = get_existing_record(res)
          parent_params = make_parent_params(res, @record)
          get :edit, parent_params.merge({ res.identifier => @record.to_param })          
        end
        
        if res.denied.actions.include?(:edit)
          should_not_assign_to res.object
          should_deny_html_request(res)
        else
          should_assign_to res.object                    
          should_respond_with :success
          should_render_template :edit
          should_not_set_the_flash

          should "set @#{res.object} to requested instance" do
            assert_equal @record, assigns(res.object)
          end
          
          should "display a form" do
            assert_select "form", true, "The template doesn't contain a <form> element"            
          end
        end
      end
    end

    def make_index_html_tests(res)
      context "on GET to :index" do
        setup do
          parent_params = make_parent_params(res)
          get(:index, parent_params)          
        end

        if res.denied.actions.include?(:index)
          should_not_assign_to res.object.to_s.pluralize
          should_deny_html_request(res)          
        else
          should_respond_with :success
          should_assign_to res.object.to_s.pluralize
          should_render_template :index
          should_not_set_the_flash
        end
      end
    end

    def make_new_html_tests(res)
      context "on GET to :new" do
        setup do
          parent_params = make_parent_params(res)
          get(:new, parent_params)          
        end

        if res.denied.actions.include?(:new)
          should_not_assign_to res.object
          should_deny_html_request(res)
        else
          should_respond_with :success
          should_assign_to res.object
          should_not_set_the_flash
          should_render_template :new
          
          should "display a form" do
            assert_select "form", true, "The template doesn't contain a <form> element"            
          end
        end
      end
    end

    def make_destroy_html_tests(res)
      context "on DELETE to :destroy" do
        setup do
          @record = get_existing_record(res)
          parent_params = make_parent_params(res, @record)
          delete :destroy, parent_params.merge({ res.identifier => @record.to_param })
        end
        
        if res.denied.actions.include?(:destroy)
          should_deny_html_request(res)
          
          should "not destroy record" do
            assert @record.reload
          end
        else
          should_set_the_flash_to res.destroy.flash

          should "redirect to #{res.destroy.redirect}" do
            record = @record
            assert_redirected_to eval(res.destroy.redirect, self.send(:binding), __FILE__, __LINE__), 
                                 "Flash: #{flash.inspect}"
          end
          
          should "destroy record" do
            assert_raises(ActiveRecord::RecordNotFound) { @record.reload }
          end
        end
      end
    end

    def make_create_html_tests(res)
      context "on POST to :create" do
        setup do
          parent_params = make_parent_params(res)
          @count = res.klass.count
          post :create, parent_params.merge(res.object => res.create.params)
        end
        
        if res.denied.actions.include?(:create)
          should_deny_html_request(res)
          should_not_assign_to res.object
          
          should "not create new record" do
            assert_equal @count, res.klass.count
          end          
        else
          should_assign_to res.object
          should_set_the_flash_to res.create.flash

          should "not have errors on @#{res.object}" do
            assert_equal [], assigns(res.object).errors.full_messages, "@#{res.object} has errors:"            
          end
          
          should "redirect to #{res.create.redirect}" do
            record = assigns(res.object)
            assert_redirected_to eval(res.create.redirect, self.send(:binding), __FILE__, __LINE__)
          end          
        end      
      end
    end

    def make_update_html_tests(res)
      context "on PUT to :update" do
        setup do
          @record = get_existing_record(res)
          parent_params = make_parent_params(res, @record)
          put :update, parent_params.merge(res.identifier => @record.to_param, res.object => res.update.params)
        end

        if res.denied.actions.include?(:update)
          should_not_assign_to res.object
          should_deny_html_request(res)
        else
          should_assign_to res.object

          should "not have errors on @#{res.object}" do
            assert_equal [], assigns(res.object).errors.full_messages, "@#{res.object} has errors:"
          end
          
          should "redirect to #{res.update.redirect}" do
            record = assigns(res.object)
            assert_redirected_to eval(res.update.redirect, self.send(:binding), __FILE__, __LINE__)            
          end

          should_set_the_flash_to(res.update.flash)
        end
      end
    end

    def should_deny_html_request(res)
      should "be denied" do
        assert_html_denied(res)
      end
    end
  end

  def assert_html_denied(res)
    assert_redirected_to eval(res.denied.redirect, self.send(:binding), __FILE__, __LINE__), 
                         "Flash: #{flash.inspect}"
    assert_contains(flash.values, res.denied.flash)
  end

end

module ThoughtBot::Shoulda::XmlTests
  def self.included(other)
    other.class_eval do
      extend ThoughtBot::Shoulda::XmlTests::ClassMethods
    end
  end
  
  module ClassMethods
    def make_show_xml_test(res)
      should "get show for @#{res.object} as xml" do
        @request.accept = "application/xml"

        record        = get_existing_record(res)
        parent_params = make_parent_params(res, record)

        get :show, parent_params.merge({ res.identifier => record.to_param })

        assert_xml_response
        assert_response :success
        assert_select "#{res.object.to_s.dasherize}", 1, 
                      "Can't find <#{res.object.to_s.dasherize.pluralize}/> in \n#{@response.body}"
      end
    end

    def make_index_xml_test(res)
      should "get index as xml" do
        @request.accept = "application/xml"

        parent_params = make_parent_params(res)

        get(:index, parent_params)

        assert_xml_response
        assert_response :success
        assert_select "#{res.object.to_s.dasherize.pluralize}", 1, 
                      "Can't find <#{res.object.to_s.dasherize.pluralize}/> in \n#{@response.body}"
      end
    end

    def make_destroy_xml_test(res)
      should "destroy @#{res.object} on 'delete' to destroy action as xml" do
        @request.accept = "application/xml"

        record = get_existing_record(res)
        parent_params = make_parent_params(res, record)

        assert_difference(res.klass, :count, -1) do
          delete :destroy, parent_params.merge({ res.identifier => record.to_param })
          assert_xml_response
          assert_response :success
          assert_match(/^\s*$/, @response.body, "The response body was not empty:")
        end
      end
    end  

    def make_create_xml_test(res)
      should "create #{res.klass} record on post to 'create' as xml" do
        @request.accept = "application/xml"

        assert_difference(res.klass, :count, 1) do
          # params = res.parent_params.merge(res.object => res.create.params)
          parent_params = make_parent_params(res)

          post :create, parent_params.merge(res.object => res.create.params)

          assert_xml_response
          assert_response :created
          assert record = assigns(res.object), "@#{res.object} not set after create"
          assert_equal [], record.errors.full_messages, "@#{res.object} has errors:"
          assert_equal eval(res.create.redirect, self.send(:binding), __FILE__, __LINE__),
                       @response.headers["Location"]
        end      
      end
    end

    def make_update_xml_test(res)
      should "update #{res.klass} record on put to :update as xml" do
        @request.accept = "application/xml"

        record = get_existing_record(res)
        parent_params = make_parent_params(res, record)

        put :update, parent_params.merge(res.identifier => record.to_param, res.object => res.update.params)

        assert_xml_response
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
  end
end

class Test::Unit::TestCase
  include ThoughtBot::Shoulda::HtmlTests
  # include ThoughtBot::Shoulda::DeniedHtmlTests
  # include ThoughtBot::Shoulda::XmlTests
  
  class ResourceOptions
    class ActionOptions
      attr_accessor :redirect, :flash, :params, :actions
    end

    attr_accessor :identifier, :klass, :object, :parent, 
                  :actions, :formats, :test_xml_actions, 
                  :create, :update, :destroy, :denied

    alias parents parent
    alias parents= parent=
    
    def initialize
      @create  = ActionOptions.new
      @update  = ActionOptions.new
      @destroy = ActionOptions.new
      @denied  = ActionOptions.new
      @actions = [:index, :show, :new, :edit, :create, :update, :destroy]
      @formats = [:html, :xml]
      @denied.actions = []
    end
    
    def normalize!(target)
      @denied.actions  = @denied.actions.map(&:to_sym)
      @actions         = @actions.map(&:to_sym)
      @formats         = @formats.map(&:to_sym)
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
    
    resource.formats.each do |format|
      resource.actions.each do |action|
        if self.respond_to? :"make_#{action}_#{format}_tests"
          self.send(:"make_#{action}_#{format}_tests", resource) 
        else
          should "test #{action} #{format}" do
            flunk "Test for #{action} as #{format} not implemented"
          end
        end
      end
    end
  end
  
  protected

  class << self
    include ThoughtBot::Shoulda::Private

    def should_set_the_flash_to(val)
      should "have #{val.inspect} in the flash" do
        assert_contains flash.values, val, ", Flash: #{flash.inspect}"            
      end
    end
    
    def should_not_set_the_flash
      should "not set the flash" do
        assert_equal({}, flash, "Flash was set to:\n#{flash.inspect}")
      end
    end
        
    def should_assign_to(name)
      should "assign @#{name}" do
        assert assigns(name.to_sym), "The show action isn't assigning to @#{name}"
      end
    end

    def should_not_assign_to(name)
      should "not assign to @#{name}" do
        assert !assigns(name.to_sym), "@#{name} was visible"
      end
    end

    def should_respond_with(response)
      should "respond with #{response}" do
        assert_response response
      end
    end
    
    def should_render_template(template)
      should "render '#{template}' template" do            
        assert_template template.to_s
      end
    end
  end
  
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

  def assert_xml_response
    assert_equal "application/xml; charset=utf-8", @response.headers['Content-Type'], "Body: " + @response.body.first(100) + '...'
  end
  
end
