class MobileIosController < MobileController
  unloadable
  
  accept_api_auth :init_notify, :show, :grant_push, :regist_device_token, :sound_on_off

  def show
    begin
      @msgs = IosNotification.notifications params[:device_token]    
      respond_to { |format| format.api }
    rescue Exception => ex
      respond_to { |format| format.api { render_validation_exception(ex) } }
    end      
  end
  
  def init_notify
    begin
      IosNotification.init_notifications params[:device_token]      
      respond_to { |format| format.api { render_api_ok } }
    rescue Exception => ex
      respond_to { |format| format.api { render_validation_exception(ex) } }      
    end
  end

  def grant_push
    begin
      user = MobileUser.find :first, :conditions => ["os = 'code_os_ios' and mobile_key = ?", params[:device_token]]
      
      if user
        flag_bit = params[:flag] == 'on' ? 1 : 0
        user.update_attributes!({:grant_push => flag_bit})
        respond_to { |format| format.api { render_api_ok } }
      end
    rescue Exception => ex
      respond_to { |format| format.api { render_validation_exception(ex) } }
     end
  end
  
  def sound_on_off
    begin
      user = MobileUser.find :first, :conditions => ["os = 'code_os_ios' and mobile_key = ?", params[:device_token]]
      
      if user
        flag_bit = params[:flag] == 'on' ? 1 : 0
        user.update_attributes!({:sound_on_off => flag_bit})
        respond_to { |format| format.api { render_api_ok } }
      end
    rescue Exception => ex
      respond_to { |format| format.api { render_validation_exception(ex) } }
     end
  end  
  
  def regist_device_token
    begin
      user = User.current
      if user.mobile_status == MobileUser::STATUS_APPROVE_COMPLETE
        user.update_attributes!({:mobile_key => params[:device_token]})
        respond_to { |format| format.api { render_api_ok } }    
      else
        raise l(:notice_account_not_approve)      
      end  
    rescue Exception => ex
      respond_to { |format| format.api { render_validation_exception(ex) } }
    end
  end

end