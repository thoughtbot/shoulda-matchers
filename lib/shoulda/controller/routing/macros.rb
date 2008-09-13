module ThoughtBot
  module Shoulda
    module Controller
      module Routing
        module Macros
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