require_dependency 'user'

module Eyemine
  module Patches
    
    module UserPatch
    
      def self.included(base) # :nodoc:
        base.send(:include, InstanceMethods)
      end
    
      module InstanceMethods
        # include ContactsHelper

        def canMobileNotify?                    
          self.mobile_status == MobileUser::STATUS_APPROVE_COMPLETE && !self.mobile_key.blank? && self.grant_push 
        end
        
        def android?
          return self.os == 'code_os_android'
        end
        
        def ios?
          return self.os == 'code_os_ios'
        end
                  
      end
            
    end

  end
end

unless User.included_modules.include?(Eyemine::Patches::UserPatch)
  User.send(:include, Eyemine::Patches::UserPatch)
end