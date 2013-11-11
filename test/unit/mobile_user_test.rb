# encoding:UTF-8

require File.expand_path('../../test_helper', __FILE__)

class MobileUserTest < ActiveSupport::TestCase
   
  def test_allowed_to?()  
      action = {:controller => "mobile_issues", :action => "show"}
      project = Project.find(8)
      user = User.find(398)         
        
      puts "$$$project.allowed = #{project.allows_to?(action)}"    
          
      roles = user.roles_for_project(project)
      
      puts  "$$$roles = #{roles.inspect}"
      
      bool = false
      bool = roles.any? do |role|
        (project.is_public? || role.member?) &&
        role.allowed_to?(action)
      end
      
      assert bool
  end
  
end
