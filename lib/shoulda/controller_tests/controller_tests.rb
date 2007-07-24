module ThoughtBot # :nodoc:
  module Shoulda # :nodoc:
    # = Macro test helpers for your controllers
    #
    module Controller
      def self.included(other) # :nodoc:
        other.class_eval do
          extend  ThoughtBot::Shoulda::Controller::ClassMethods
          include ThoughtBot::Shoulda::Controller::InstanceMethods
          ThoughtBot::Shoulda::Controller::ClassMethods::VALID_FORMATS.each do |format|
            include "ThoughtBot::Shoulda::Controller::#{format.to_s.upcase}".constantize
          end
        end
      end
      
      module ClassMethods
        # Formats tested by #should_be_restful.  Defaults to [:html, :xml]
        VALID_FORMATS = Dir.glob(File.join(File.dirname(__FILE__), 'formats', '*')).map { |f| File.basename(f, '.rb') }.map(&:to_sym) # :doc:
        VALID_FORMATS.each {|f| require "shoulda/controller_tests/formats/#{f}.rb"}

        # Actions tested by #should_be_restful
        VALID_ACTIONS = [:index, :show, :new, :edit, :create, :update, :destroy] # :doc:

        class ResourceOptions
          class ActionOptions
            # String eval'd to get the target of the redirection
            attr_accessor :redirect

            # String or Regexp describing a value expected in the flash
            attr_accessor :flash
            
            # Hash describing the params that should be sent in with this action
            attr_accessor :params
            
            # Actions that should be denied (only used by resource.denied)
            attr_accessor :actions
          end

          # Name of key in params that references the primary key.  Will almost always be :id (default)
          attr_accessor :identifier
          
          # Name of the ActiveRecord class this resource is responsible for.  Automatically determined from
          # test class if not explicitly set.
          attr_accessor :klass

          # Name of the instantiated ActiveRecord object that should be used by some of the tests.  
          # Defaults to the underscored name of the AR class.  CompanyManager => :company_manager
          attr_accessor :object

          # Name of the parent AR objects.
          attr_accessor :parent
          alias parents parent
          alias parents= parent=
          
          # Actions that should be tested.  Must be a subset of #VALID_ACTIONS
          attr_accessor :actions

          # Formats that should be tested.  Must be a subset of #VALID_FORMATS
          attr_accessor :formats
          
          # ActionOptions object
          attr_accessor :create

          # ActionOptions object
          attr_accessor :update

          # ActionOptions object
          attr_accessor :destroy

          # ActionOptions object
          attr_accessor :denied

          def initialize # :nodoc:
            @create  = ActionOptions.new
            @update  = ActionOptions.new
            @destroy = ActionOptions.new
            @denied  = ActionOptions.new
            @actions = VALID_ACTIONS
            @formats = VALID_FORMATS
            @denied.actions = []
          end

          def normalize!(target) # :nodoc:
            @denied.actions  = @denied.actions.map(&:to_sym)
            @actions         = @actions.map(&:to_sym)
            @formats         = @formats.map(&:to_sym)
            
            ensure_valid_members(@actions,        VALID_ACTIONS, 'actions')
            ensure_valid_members(@denied.actions, VALID_ACTIONS, 'denied.actions')
            ensure_valid_members(@formats,        VALID_FORMATS, 'formats')
            
            @identifier    ||= :id
            @klass         ||= target.name.gsub(/ControllerTest$/, '').singularize.constantize
            @object        ||= @klass.name.tableize.singularize
            @parent        ||= []
            @parent          = [@parent] unless @parent.is_a? Array

            singular_args = @parent.map {|n| "@#{object}.#{n}"}
            @destroy.redirect ||= "#{@object.pluralize}_url(#{singular_args.join(', ')})" 

            singular_args << "@#{object}"
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
          
          private
          
          def ensure_valid_members(ary, valid_members, name)  # :nodoc:
            invalid = ary - valid_members
            raise ArgumentError, "Unsupported #{name}: #{invalid.inspect}" unless invalid.empty?
          end
        end

        # Bunch of documentation and examples for this one.
        def should_be_restful(&blk) # :yields: resource
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

        # Macro that creates a test asserting that the flash contains the given value.
        # val can be a String or a Regex
        def should_set_the_flash_to(val)
          should "have #{val.inspect} in the flash" do
            assert_contains flash.values, val, ", Flash: #{flash.inspect}"            
          end
        end
    
        # Macro that creates a test asserting that the flash is empty
        def should_not_set_the_flash
          should "not set the flash" do
            assert_equal({}, flash, "Flash was set to:\n#{flash.inspect}")
          end
        end
        
        # Macro that creates a test asserting that the controller assigned to @name
        def should_assign_to(name)
          should "assign @#{name}" do
            assert assigns(name.to_sym), "The show action isn't assigning to @#{name}"
          end
        end

        # Macro that creates a test asserting that the controller did not assign to @name
        def should_not_assign_to(name)
          should "not assign to @#{name}" do
            assert !assigns(name.to_sym), "@#{name} was visible"
          end
        end

        # Macro that creates a test asserting that the controller responded with a 'response' status code.
        # Example:
        #
        #   should_respond_with :success
        def should_respond_with(response)
          should "respond with #{response}" do
            assert_response response
          end
        end
    
        # Macro that creates a test asserting that the controller rendered the given template.
        # Example:
        #
        #   should_render_template :new
        def should_render_template(template)
          should "render '#{template}' template" do            
            assert_template template.to_s
          end
        end

        def should_redirect_to(url)
          should "redirect to #{url}" do
            instantiate_variables_from_assigns do
              assert_redirected_to eval(url, self.send(:binding), __FILE__, __LINE__)
            end
          end
        end
      end

      module InstanceMethods

        private
        
        def instantiate_variables_from_assigns(*names, &blk)
          old = {}
          names = @response.template.assigns.keys if names.empty?
          names.each do |name|
            old[name] = instance_variable_get("@#{name}")
            instance_variable_set("@#{name}", assigns(name.to_sym))
          end
          blk.call
          names.each do |name|
            instance_variable_set("@#{name}", old[name])
          end
        end

        def get_existing_record(res) # :nodoc:
          returning(instance_variable_get("@#{res.object}")) do |record|
            assert(record, "This test requires you to set @#{res.object} in your setup block")    
          end
        end

        def make_parent_params(resource, record = nil, parent_names = nil) # :nodoc:
          parent_names ||= resource.parents.reverse

          return {} if parent_names == [] # Base case

          parent_name = parent_names.shift

          parent = record ? record.send(parent_name) : parent_name.to_s.classify.constantize.find(:first)

          { :"#{parent_name}_id" => parent.id }.merge(make_parent_params(resource, parent, parent_names))
        end

      end
    end  
  end
end

