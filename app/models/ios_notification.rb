class IosNotification < ActiveRecord::Base
  unloadable
  
  include Redmine::SafeAttributes
  
  safe_attributes 'user_id',
                  'device_token',                  
                  'alert',
                  'created_on',
                  'issue_id'
                  
  def self.badge(device_token)
    return IosNotification.count :conditions => ["device_token = ?", device_token]
  end
  
  def self.notifications(device_token)
    return IosNotification.find :all, :conditions => ["device_token = ?", device_token]
  end
  
  def self.init_notifications(device_token)
    IosNotification.delete_all(["device_token = ?", device_token])
  end
  
  def self.sound(sound_on_off_flag)
    return sound_on_off_flag ? 'default' : 'MMPSilence.wav'
  end
                  
end