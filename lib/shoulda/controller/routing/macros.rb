module ThoughtBot
  module Shoulda
    module Controller
      module Routing
        module Macros
          # Macro that creates a routing test. It tries to use the given HTTP
          # +method+ on the given +path+, and asserts that it routes to the
          # given +options+.
          #
          # If you don't specify a :controller, it will try to guess the controller
          # based on the current test.
          #
          # +to_param+ is called on the +options+ given.
          #
          # Examples:
          #
          #   should_route :get, '/posts', :action => :index
          #   should_route :post, '/posts', :controller => :posts, :action => :create
          #   should_route :get, '/posts/1', :action => :show, :id => 1
          #   should_route :put, '/posts/1', :action => :update, :id => "1"
          #   should_route :delete, '/posts/1', :action => :destroy, :id => 1
          #   should_route :get, '/posts/new', :action => :new
          # 
          def should_route(method, path, options)
            unless options[:controller]
              options[:controller] = self.name.gsub(/ControllerTest$/, '').tableize
            end
            options[:controller] = options[:controller].to_s
            options[:action] = options[:action].to_s

            populated_path = path.dup
            options.each do |key, value|
              options[key] = value.to_param if value.respond_to? :to_param
              populated_path.gsub!(key.inspect, value.to_s)
            end

            should_name = "route #{method.to_s.upcase} #{populated_path} to/from #{options.inspect}"

            should should_name do
              assert_routing({:method => method, :path => populated_path}, options)
            end
          end
        end
      end
    end
  end
end