module Shoulda # :nodoc:
  module ActionController # :nodoc:
    module Matchers

      # Ensures that requesting +path+ using +method+ routes to +options+.
      #
      # If you don't specify a controller, it will use the controller from the
      # example group.
      #
      # +to_param+ is called on the +options+ given.
      #
      # Examples:
      #
      #   it { should route(:get, "/posts").
      #                 to(:controller => :posts, :action => :index) }
      #   it { should route(:get, "/posts/new").to(:action => :new) }
      #   it { should route(:post, "/posts").to(:action => :create) }
      #   it { should route(:get, "/posts/1").to(:action => :show, :id => 1) }
      #   it { should route(:edit, "/posts/1").to(:action => :show, :id => 1) }
      #   it { should route(:put, "/posts/1").to(:action => :update, :id => 1) }
      #   it { should route(:delete, "/posts/1").
      #                 to(:action => :destroy, :id => 1) }
      #   it { should route(:get, "/users/1/posts/1").
      #                 to(:action => :show, :id => 1, :user_id => 1) }
      def route(method, path)
        RouteMatcher.new(method, path, self)
      end

      class RouteMatcher # :nodoc:

        def initialize(method, path, context)
          @method  = method
          @path    = path
          @context = context
        end

        def to(params)
          @params = params
          self
        end

        def in_context(context)
          @context = context
          self
        end

        def matches?(controller)
          @controller = controller
          guess_controller!
          stringify_params!
          route_recognized?
        end

        attr_reader :failure_message, :negative_failure_message

        def description
          "route #{@method.to_s.upcase} #{@path} to/from #{@params.inspect}"
        end

        private

        def guess_controller!
          @params[:controller] ||= @controller.controller_path
        end

        def stringify_params!
          @params.each do |key, value|
            @params[key] = value.is_a?(Array) ? value.collect {|v| v.to_param } : value.to_param
          end
        end

        def route_recognized?
          begin
            @context.send(:assert_routing, 
                          { :method => @method, :path => @path },
                          @params)

            @negative_failure_message = "Didn't expect to #{description}"
            true
          rescue ::ActionController::RoutingError => error
            @failure_message = error.message
            false
          rescue Test::Unit::AssertionFailedError => error
            @failure_message = error.message
            false
          end
        end

      end

    end
  end
end
