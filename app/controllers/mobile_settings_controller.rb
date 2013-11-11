class MobileSettingsController < MobileController
  unloadable

  layout 'admin'
  
  before_filter :require_admin

  def edit
    @settings = Setting.plugin_eyemine        
  end
  
  def update
    settings = Setting.plugin_eyemine    
    settings = {} if !settings.is_a?(Hash)
    settings.merge!(params[:settings])
        
    Setting.plugin_eyemine = settings
    flash[:notice] = l(:notice_successful_update)
    redirect_to :action => 'edit'
  end
  
end