# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

get 'mobile', :to => 'mobile#check_live'

get 'mobile/users', :to => 'mobile_users#index'
get 'mobile/users/:id', :to => 'mobile_users#show'
get 'mobile/users/:id/edit', :to => 'mobile_users#edit'
put 'mobile/users/:id', :to => 'mobile_users#update'
delete 'mobile/users/:id', :to => 'mobile_users#remove'
put 'mobile/users/:login/push/:flag', :to => 'mobile_users#grant_push'

get 'mobile/settings', :to => 'mobile_settings#edit'
put 'mobile/settings', :to => 'mobile_settings#update'

post 'mobile/regist', :to => 'mobile_account#regist'
post 'mobile/unregist', :to => 'mobile_account#unregist'
post 'mobile/login', :to => 'mobile_account#login'
get 'mobile/logout', :to => 'mobile_account#logout'

get 'mobile/projects', :to => 'mobile_projects#index'

get 'mobile/issues/:id', :to => 'mobile_issues#show'
get 'mobile/issues', :to => 'mobile_issues#index'
put 'mobile/issues/:id', :to =>'issues#update'

get 'mobile/ios/:device_token', :to => 'mobile_ios#show'
put 'mobile/ios/:device_token/init', :to => 'mobile_ios#init_notify'
put 'mobile/ios/:device_token/push/:flag', :to => 'mobile_ios#grant_push'
put 'mobile/ios/:device_token/sound/:flag', :to => 'mobile_ios#sound_on_off'
put 'mobile/ios/:device_token', :to => 'mobile_ios#regist_device_token'