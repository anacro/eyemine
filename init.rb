Rails.configuration.to_prepare do
  require_dependency 'config'
  require_dependency 'hooks/controller_issues_hook_listener'
  require_dependency 'hooks/views_layouts_hook_listener'    
  require_dependency 'patches/user_patch'
  require_dependency 'apns/apns'
  require_dependency 'gcm/gcm'  
end

Redmine::Plugin.register :eyemine do
  name 'Eyemine plugin'
  author 'Author name'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'
  
  settings :default => {
    'try_login_limit' => '3'    
  }
    
  menu :admin_menu, :mobile_users, {:controller => 'mobile_users', :action => 'index'}, :caption => "Eyemine"

  project_module :issue_tracking do
    permission :view_mobile_issues, {:mobile_issues => [:index, :show]}, :read => true
  end
    
end
