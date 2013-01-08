module Shoulda # :nodoc:
  module Matchers
    module ActionController # :nodoc:

      # Ensures that requesting +path+ using +method+ routes to +options+.
      #
      # If you don't specify a controller, it will use the controller from the
      # example group.
      #
      # +to_param+ is called on the +options+ given.
      #
      # Examples:
      #
      #   it { should route(:get, '/posts').
      #                 to(:controller => :posts, :action => :index) }
      #   it { should route(:get, '/posts/new').to(:action => :new) }
      #   it { should route(:post, '/posts').to(:action => :create) }
      #   it { should route(:get, '/posts/1').to(:action => :show, :id => 1) }
      #   it { should route(:get, '/posts/1/edit').to(:action => :edit, :id => 1) }
      #   it { should route(:put, '/posts/1').to(:action => :update, :id => 1) }
      #   it { should route(:delete, '/posts/1').
      #                 to(:action => :destroy, :id => 1) }
      #   it { should route(:get, '/users/1/posts/1').
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

        attr_reader :failure_message_for_should, :failure_message_for_should_not

        def to(params)
          @params = stringify_params(params)
          self
        end

        def in_context(context)
          @context = context
          self
        end

        def matches?(controller)
          guess_controller!(controller)
          route_recognized?
        end

        def description
          "route #{@method.to_s.upcase} #{@path} to/from #{@params.inspect}"
        end

        private

        def guess_controller!(controller)
          @params[:controller] ||= controller.controller_path
        end

        def stringify_params(params)
          params.each do |key, value|
            params[key] = stringify(value)
          end
        end

        def stringify(value)
          if value.is_a?(Array)
            value.map(&:to_param)
          else
            value.to_param
          end
        end

        def route_recognized?
          begin
            @context.send(:assert_routing,
                          { :method => @method, :path => @path },
                          @params)

            @failure_message_for_should_not = "Didn't expect to #{description}"
            true
          rescue ::ActionController::RoutingError => error
            @failure_message_for_should = error.message
            false
          rescue Shoulda::Matchers::AssertionError => error
            @failure_message_for_should = error.message
            false
          end
        end
      end
    end
  end
end
