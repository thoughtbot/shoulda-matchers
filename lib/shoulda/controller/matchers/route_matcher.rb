module Shoulda # :nodoc:
  module Controller # :nodoc:
    module Matchers

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
            @params[key] = value.to_param
          end
        end

        def route_recognized?
          begin
            @context.send(:assert_routing, 
                          { :method => @method, :path => @path },
                          @params)

            @negative_failure_message = "Didn't expect to #{description}"
            true
          rescue ActionController::RoutingError => error
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
