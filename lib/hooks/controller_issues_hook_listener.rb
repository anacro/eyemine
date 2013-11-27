#A plugin that insert image wiki tag of attached image file to end of description of issue when the issue is befoer save

module Eyemine    
  module Hooks
  
    include MobileIssuesHelper
  
    class ControllerIssuesHookListener < Redmine::Hook::ViewListener
    
      def initialize()
        Eyemine::APNS.host = Eyemine::Configuration[:apns_host]
        Eyemine::APNS.port = Eyemine::Configuration[:apns_port]
        Eyemine::APNS.pem = Eyemine::Configuration[:apns_cert_file]
        Rails.logger.debug "$$$notify - apns_cert_file: #{Eyemine::APNS.pem}"
        Eyemine::APNS.pass = Eyemine::Configuration[:apns_cert_pass]
      end
      
      def controller_issues_new_after_save(context={})
        controller_issues_edit_after_save(context)
      end
      
      def controller_issues_edit_after_save(context={})        
        Thread.new do
          begin
            issue = context[:issue]
            journal = context[:journal]
                        
            #registration_ids = issue.notified_users.collect(&:login)
            notified = recipients(issue, journal)
            Rails.logger.debug "$$$notify - recipients: #{notified.map(&:login).inspect}"        
            
            if notified && notified.count > 0                
                deliver_android(notified.select { |u| u.android? }, issue, journal)
                deliver_ios(notified.select { |u| u.ios? }, issue, journal)
            end
          rescue Exception => ex
            Rails.logger.error "$$$notify - error: #{ex.inspect}"
          end
        end
      end      
      
private

      def deliver_android(recipients, issue, journal)        
        author_name = journal ? journal.user.name : issue.author.name
        title = l(:text_mobile_notification, :author_name => author_name, :subject => issue.subject.html_safe) 
        msg = {:issue_id => issue.id, :title => l(:text_mobile_notification_notag, :author_name => author_name, :subject => issue.subject.html_safe)}        
        
        registration_ids = recipients.map(&:mobile_key).uniq        
        
        if registration_ids.length > 0
          Rails.logger.debug "$$$notify gcm - #{registration_ids}"
          
          data = { :data => { :title => title, :msg => msg } }
          
          result = Eyemine::GCM.send_notification(registration_ids, data)
          Rails.logger.debug "$$$notify gcm - #{result.inspect}"          
        end          
      end
      
      def deliver_ios(recipients, issue, journal)
        author_name = journal ? journal.user.name : issue.author.name
        alert = l(:text_mobile_notification_notag, :author_name => author_name, :subject => issue.subject.html_safe).byteslice(0, 120)
        message = l(:text_mobile_notification, :author_name => author_name, :subject => issue.subject.html_safe)
                
        notified = []
        recipients.uniq.each do |user|
          if IosNotification.create(:user_id => user.id, :device_token => user.mobile_key, :alert => message, :issue_id => issue.id,  :created_on => Time.now)  
            notified << Eyemine::APNS::Notification.new(user.mobile_key, :alert => alert, :badge => IosNotification.badge(user.mobile_key), :sound => IosNotification.sound(user.sound_on_off), :other => {:issue_id => issue.id, :journal_created_on => journal.created_on})            
          end
        end
        
        if notified.length > 0          
          #Rails.logger.debug "$$$notify pem - #{Eyemine::APNS.pem}"
          Rails.logger.debug "$$$notify apns - #{notified.inspect}"
          Eyemine::APNS.send_notifications(notified)
        end
      end            
      
      def recipients(issue, journal)        
        notified = assigned_users(issue, journal)
        notified += watcher_users(issue, journal)        
        notified -= journal_author(journal) if journal                          
        
        return notified
      end
      
      def assigned_users(issue, journal)
        notified = issue.notified_users.select {|u| u.canMobileNotify? }
        
        if notified && notified.count > 0 then
          if journal && journal.private_notes? then
            notified = notified.select {|u| u.allowed_to?(:view_private_notes, issue.project)}
          end
        end
        
        return notified        
      end
    
      def watcher_users(issue, journal)
        notified = issue.notified_watchers.select {|u| u.canMobileNotify? }
        
        if notified && notified.count > 0 then
          if journal && journal.private_notes? then
            notified = notified.select {|u| u.allowed_to?(:view_private_notes, issue.project)}
          end          
        end
        
        return notified
      end
      
      def journal_author(journal)
        user = User.find(journal.user_id)                
        return user && user.canMobileNotify? ? [user] : []        
      end
      
      def getMsg_origin(journal)
        if !journal.notes.blank?
          msg = journal.notes        
        else
          msg = ''
          journal.details.each do |detail|
            label = journal_detail_title(detail.property, detail.prop_key)
            old_value = journal_detail_value(detail.property, detail.prop_key, detail.old_value)
            new_value = journal_detail_value(detail.property, detail.prop_key, detail.value)
            
            if !old_value.blank? && !new_value.blank?
              msg << "\r\n" + l(:text_journal_changed, :label => label, :old => old_value, :new => new_value)
            elsif !new_value.blank?
              if detail.property == 'attr'
                msg << "\r\n" + l(:text_journal_set_to, :label => label, :value => new_value)
              else
                msg << "\r\n" + l(:text_journal_added, :label => label, :value => new_value)
              end
            elsif !old_value.blank?
              msg << "\r\n" + l(:text_journal_deleted, :label => label, :old => old_value)
            end
          end
          
          msg = msg[2, msg.size-2] unless msg.blank?
        end
        
        return msg
      end            
    
    end      
  
  end
end
