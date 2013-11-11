module MobileIssuesHelper

  include ApplicationHelper
  
  def render_api_issue_description(issue, api)    
    #html = stylesheet_link_tag( 'application', :media => 'all')
    if current_theme
      html = "<link href='http://#{request.host}:#{request.port}#{current_theme.stylesheet_path('application')}.css' media='all' rel='stylesheet' type='text/css'>"
    else
      html = "<link href='http://#{request.host}:#{request.port}/stylesheets/application.css' media='all' rel='stylesheet' type='text/css'>"
    end    
    
    html << '<div id="content"><div class="issue"><div class="description"><div class="wiki">'
    html << textilizable(issue, :description, :attachments => @issue.attachments)
    html << '</div></div></div></div>'
    
    api.description html
  end  
  
  def journal_detail_title(property, prop_key)  
    if property == 'attr'
      title = l("field_#{prop_key.gsub('_id', '')}")
  
    elsif property == 'cf'      
      begin
        title = CustomField.find_by_id(prop_key).name
      rescue
        title = prop_key
      end
    elsif property == 'attachment'
      title = l(:field_filename)
    else
      title = prop_key
    end    
    return title
  end
  
  def current_theme
    unless instance_variable_defined?(:@current_theme)
      @current_theme = Redmine::Themes.theme(Setting.ui_theme)
    end
    @current_theme
  end
  
  def journal_detail_value(property, prop_key, value)
    return '' if value.blank?
    
    if property == 'attr'
      case prop_key
      when 'status_id'
        v = IssueStatus.find_by_id(value).name
      when 'priority_id'
        v = Enumeration.find(value).name
      when 'tracker_id'
        v = Tracker.find(value).name
      when 'category_id'
        v = IssueCategory.find(value).name              
      when 'fixed_version_id'
        v = Version.find(value)
      when 'assigned_to_id'
        v = User.find(value).name
      when 'project_id'        
        v = Project.find(value).name      
        
      else
        v = value
      end      
    else
      v = value      
    end    
    return v
  rescue  
    return value
  end
  
end