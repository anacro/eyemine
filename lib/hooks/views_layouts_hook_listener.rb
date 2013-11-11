module Eyemine    
  module Hooks
    
    class ViewsLayoutsHookListener < Redmine::Hook::ViewListener
      def view_layouts_base_html_head(context={})
        return stylesheet_link_tag('eyemine.css', :plugin => 'eyemine')
      end
    end
    
  end
end