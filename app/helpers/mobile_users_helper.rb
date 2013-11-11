module MobileUsersHelper

  def edit_mobile_user_path(mobileUser)
    return "/mobile/users/#{mobileUser.id}/edit"
  end
  
  def users_mobile_status_options_for_select(selected, canSelectAll=true)
    options = []
    options << [l(:label_all), ''] if canSelectAll == true
    options << [l(:code_mobile_status_1), '1']
    options << [l(:code_mobile_status_2), '2']
    options << [l(:code_mobile_status_3), '3']        
    options_for_select(options, selected.to_s)
  end
  
end
