class MobileAccountController < MobileController
  unloadable
  
  helper :custom_fields
  include CustomFieldsHelper  
     
  skip_before_filter :check_if_login_required
  
  accept_api_auth :regist, :unregist, :login, :logout
  
  def regist
    user = basic_authenticate()
        
    if user.already_registing? then
      raise l(:notice_already_mobile_registing) 
    end
    
    if user.already_registed? then
      raise l(:notice_already_mobile_registed) 
    end
    
    if user.blocked? then
      raise l(:notice_mobile_blocked) 
    end
        
    if user.regist(params) then    
      respond_to do |format|
        format.api  { render_api_ok }
      end
    else
      render_validation_errors(user)
    end    
     
  rescue Exception => ex
      respond_to do |format|               
        format.api  { render_validation_exception(ex) }
      end
  end
  
  def unregist  
    user = basic_authenticate()
    
    raise l(:notice_missmatching_mobile_auth) if user.udid != params[:udid]
      
    if user.unregist() then
      respond_to do |format|
        format.api  { render_api_ok }
      end    
    else
      render_validation_errors(user)
    end
  end

  # Login request and validation
  def login    
      authenticate_user    
      respond_to do |format|
        format.api  { 
          render :template => 'mobile_users/show.api.rsb', :status => :ok, :layout => nil 
        }
      end
      
  rescue Exception => ex
      respond_to do |format|               
        format.api  { render_validation_exception(ex) }
      end
  end
  
  def logout    
    #if request.post?
      token = Token.find_token('api', params[:key])
      token.destroy if token
      respond_to do |format|        
        format.api  { render_api_ok }
      end
    #end  
  end
  
private

  def basic_authenticate()
    login = params[:username].to_s
    password = params[:password].to_s

    if login.empty? || password.empty? then
      invalid_credentials
    end
      
    user = MobileUser.find_by_login(login)    
    if user.nil? || !user.active? || !user.check_password?(password) then 
      invalid_credentials
    end
    
    return user    
  end

  def authenticate_user
    password_authentication    
  end

  def password_authentication
    @user = MobileUser.try_to_login(params[:username], params[:password])

    if @user.nil?
      invalid_credentials
    elsif @user.new_record?
      raise "not support AuthSource"
    else
      # Valid user
      checkMobileUser(@user)  
      successful_authentication(@user)      
    end
  end  
  
  def checkMobileUser(user)
    raise l(:notice_not_mobile_user) if user.mobile_status.blank?
    raise l(:notice_already_mobile_registing) if user.already_registing?
    
    raise l(:notice_account_blocked, :login_err_count => user.login_err_count) if user.login_limit_exceed?
    raise l(:notice_mobile_blocked) if user.blocked?
    
    if user.udid != params[:udid] then    
      if user.increment!(:login_err_count) && user.login_limit_exceed? then
        user.block!
        raise l(:notice_account_blocked, :login_err_count => user.login_err_count)
      end
      
      raise l(:notice_missmatching_mobile_auth)
    end    
  end
    
  def successful_authentication(user)    
    if user.update_column(:mobile_last_login_on, Time.now) then
      logger.info "Successful authentication for '#{user.login}' from #{request.remote_ip} at #{Time.now.utc}"
      
      user.reset_api_key
      
      self.logged_user = user
      
      # generate a key and set cookie if autologin
      if params[:autologin] && Setting.autologin?
        set_autologin_cookie(user)
      end
    else
      raise "fail update login info"
    end
  end  
  
  def invalid_credentials
    logger.warn "Failed login for '#{params[:username]}' from #{request.remote_ip} at #{Time.now.utc}"
    raise l(:notice_account_invalid_creditentials)
  end
  

end
