def stylesheets_full_list
  %w(css/solarized.css css/bootstrap.css css/global.css) + super
end

def javascripts
  javascripts = super
  javascripts.insert 1, 'js/jquery.stickyheaders.js'
end

def class_list(root = Registry.root, tree = TreeContext.new)
  out = String.new("")
  children = run_verifier(root.children)
  if root == Registry.root
    children += @items.select {|o| o.namespace.is_a?(CodeObjects::Proxy) }
  end
  children.compact.sort_by(&:path).each do |child|
    next unless child.is_a?(CodeObjects::NamespaceObject)
    name = child.namespace.is_a?(CodeObjects::Proxy) ? child.path : child.name
    has_children = run_verifier(child.children).any? {|o| o.is_a?(CodeObjects::NamespaceObject) }
    out << "<li id='object_#{child.path}' class='#{tree.classes.join(' ')}'>"
    out << "<div class='item'>"
    out << "<a class='toggle'></a> " if has_children
    out << linkify(child, name)
    out << " &lt; #{child.superclass.name}" if child.is_a?(CodeObjects::ClassObject) && child.superclass
    out << "<small class='search_info'>"
    out << child.namespace.title
    out << "</small>"
    out << "</div>"
    tree.nest do
      out << "<ul>#{class_list(child, tree)}</ul>" if has_children
    end
    out << "</li>"
  end
  out
end
