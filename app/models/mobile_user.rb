class MobileUser < User
  unloadable
  self.inheritance_column = :_type_disabled

  include Redmine::SafeAttributes  
                                                                  
  scope :is_mobile, lambda { where("#{User.table_name}.mobile_status in (2,3)") }
  scope :mobile_status, lambda {|arg| where(arg.blank? ? nil : {:mobile_status => arg.to_i}) }
  
  validates_presence_of :os, :udid
  validates_format_of :mobile_key, :udid, :with => /\A[a-zA-Z0-9_\-]*\z/  
  
  safe_attributes 'os',
                  'mobile_key',                  
                  'udid',
                  'mobile_status',
                  'mobile_last_login_on',
                  'grant_push',
                  'sound_on_off'
                  
  STATUS_NONE             = 0
  STATUS_APPROVE_REQUEST  = 1
  STATUS_APPROVE_COMPLETE = 2
  STATUS_ACCOUNT_BLOCK    = 3
  
  LOGIN_LIMIT_EXCEED = Setting.plugin_eyemine['try_login_limit'].to_i
                  
  def already_registing?
    self.mobile_status == STATUS_APPROVE_REQUEST
  end
  
  def already_registed?
    self.mobile_status == STATUS_APPROVE_COMPLETE
  end
  
  def blocked?
    self.mobile_status == STATUS_ACCOUNT_BLOCK
  end                   
                  
  def isMobile?
    self.mobile_status == STATUS_APPROVE_COMPLETE || self.mobile_status == STATUS_ACCOUNT_BLOCK
  end
    
  def login_limit_exceed?
    self.login_err_count >= LOGIN_LIMIT_EXCEED
  end
  
  def visible?(usr=nil)
    true
  end
  
  def regist(params)
    return self.update_attributes({:os => params[:os], :mobile_key => params[:mobile_key], :udid => params[:udid], :mobile_status => 1, :grant_push => 1, :sound_on_off => 1})    
  end
  
  def unregist()
    self.attributes = { :os => nil, :mobile_key => nil, :udid => nil, :mobile_status => nil, :login_err_count => 0, :grant_push => nil, :sound_on_off => nil }            
    if self.save(:validate => false) then
      self.api_token.destroy if self.api_token #기존 api_token으로 api 호출을 막기 위해 제거
      return true;
    end
  end
  
  def block!
    if update_column(:mobile_status, STATUS_ACCOUNT_BLOCK) then    
      self.api_token.destroy! if self.api_token #기존 api_token으로 api 호출을 막기 위해 제거
    end
  end
  
  def reset_api_key
    if self.api_token
      self.api_token.destroy
      self.reload # 하지 않은면 api_token이 nill로 변경되지 않으 토큰이 생성되지 않음 
    end
    return self.api_key
  end
          
end
