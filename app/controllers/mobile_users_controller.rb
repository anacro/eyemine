class MobileUsersController < MobileController
  unloadable
  
  layout 'admin'  
  
  helper :sort
  include SortHelper
    
  helper :custom_fields
  include CustomFieldsHelper
  
  helper :users
  include UsersHelper
    
  before_filter :require_admin, :except => [:show, :grant_push]  
  before_filter :find_user, :only => [:show, :edit, :update, :remove]
  
  accept_api_auth :show, :grant_push
  
  def index
    sort_init 'mobile_status', 'desc'
    sort_update %w(mobile_status login firstname lastname os mobile_last_login_on)
    
    @limit = per_page_option
            
    @mobile_status = params[:mobile_status] || MobileUser::STATUS_APPROVE_REQUEST

    scope = MobileUser.logged.mobile_status(@mobile_status)
    scope = scope.like(params[:name]) if params[:name].present?    
    
    @user_count = scope.count
    @user_pages = Paginator.new @user_count, @limit, params['page']
    @offset ||= @user_pages.offset
    @users =  scope.order(sort_clause).limit(@limit).offset(@offset).all
    
    respond_to do |format|
      format.html {        
        render :layout => !request.xhr?
      }      
    end
  end
  
  def edit        
  end
  
  def update  
    if params[:user][:mobile_status].to_i == MobileUser::STATUS_ACCOUNT_BLOCK #관리자에 의한 계정 블럭
      @user.block!
    else
      @user.login_err_count = 0 #Block을 풀어줌(잘못된 로그인 시도에 의한 블럭)
    end
    
    if @user.update_attributes(params[:user])
      flash[:notice] = l(:notice_successful_update)
      respond_to do |format| 
        format.html { redirect_to :action => "index" }
      end  
    else           
      respond_to do |format|
        format.html { render :action => "edit"}  
      end
    end
  end
  
  def remove
    if @user.unregist() then
      flash[:notice] = l(:notice_successful_update)      
      respond_to do |format| 
        format.html { redirect_to :action => "index" }
      end      
    else
      respond_to do |format|
        format.html { render :action => "edit"}  
      end    
    end
  end

  def show
    respond_to do |format|     
      format.api {
        begin
          render :action => 'show'
        rescue Exception => ex
          render_validation_exception(ex)  
        end
      }
    end
  end
  
  def grant_push
    begin
      user = MobileUser.find_by_login(params[:login])
      
      if user
        flag_bit = params[:flag] == 'on' ? 1 : 0        
        user.attributes = { :grant_push => flag_bit }        
        user.save!(:validate => false)
        
        respond_to { |format| format.api { render_api_ok } }
      end
    rescue Exception => ex
      respond_to { |format| format.api { render_validation_exception(ex) } }
     end
  end  

private

  def find_user
    @user = MobileUser.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    errMsg = "not exist user - #{params[:id]}"
    render_validation_messages([errMsg])    
  end

end