class MobileProjectsController < MobileController
  unloadable
  
  accept_api_auth :index
  
  def index
    respond_to do |format|    
      format.api  {
        @offset, @limit = api_offset_and_limit
        @project_count = Project.visible.count
        @projects = Project.visible.offset(@offset).limit(@limit).order('lft').all
      }
    end
  end

end