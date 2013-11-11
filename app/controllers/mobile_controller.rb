# encoding:UTF-8

# http status에  실패코드를 던질 경우 클라이어트에서 HttpException으로 받아서 xml 파싱을 못함
# 그래서 200 OK로 변경함
class MobileController < ApplicationController
  unloadable
  
  skip_before_filter :check_if_login_required
  accept_api_auth :check_live
  
  def check_live
   respond_to { |format| format.api { render_api_ok } }
  end
  
  def render_validation_exception(exception)
    @error_messages = [exception]
    render :template => 'common/error_messages.api', :status => :ok, :layout => nil
  end
  
  def render_validation_messages(errMsgs)
    @error_messages = errMsgs
    render :template => 'common/error_messages.api', :status => :ok, :layout => nil
  end
  
  def render_validation_errors(objects)
    if objects.is_a?(Array)
      @error_messages = objects.map {|object| object.errors.full_messages}.flatten
    else
      @error_messages = objects.errors.full_messages
    end
    
    #@error_messages = "1069999422:#{@error_messages}"
    
    render :template => 'common/error_messages.api', :status => :ok, :layout => nil
  end  
  
end