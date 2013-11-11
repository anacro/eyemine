# encoding:UTF-8

require File.expand_path('../../test_helper', __FILE__)

class IosNotificationTest < ActiveSupport::TestCase
   
  def diable_test_ssl_connect
    token =  ["749b7bf3a329920f0485c9b37d640cf3927c5b93b353d9c649f52095256d8ed6"].pack('H*')
    
    payload = {"aps" => {"alert" => "테스트", "badge" => 1, "sound" => 'default'}}
    json = payload.to_json    
    
    apnsMessage = "\0\0 #{token}\0#{json.length.chr}#{json}"
    
    cert = File.read('DevPMSPlus.pem')
    #cert = File.read('apns-dev-cert.cer')
    #key =  File.read('apns-dev-key.pem')
    
    context = OpenSSL::SSL::SSLContext.new("SSLv3")
    context.cert = OpenSSL::X509::Certificate.new(cert)
    context.key  = OpenSSL::PKey::RSA.new(cert)
    #context.key  = OpenSSL::PKey::RSA.new(cert, 'eyedentity1')
        
    sock = TCPSocket.new('gateway.sandbox.push.apple.com', 2195)
    ssl = OpenSSL::SSL::SSLSocket.new(sock,context)
    ssl.connect

    ssl.write(apnsMessage)
        
    ssl.close
    sock.close
  end
  
  def diable_test_notification    
    token = "749b7bf3a329920f0485c9b37d640cf3927c5b93b353d9c649f52095256d8ed6"
    n = PmsPlus::APNS::Notification.new(token, "테스트1")
    puts n.inspect
    
    PmsPlus::APNS.host = Eyedentt::Configuration[:apns_host]
    PmsPlus::APNS.port = Eyedentt::Configuration[:apns_port]
    PmsPlus::APNS.pem = Eyedentt::Configuration[:apns_cert_file]
    PmsPlus::APNS.pass = Eyedentt::Configuration[:apns_cert_pass]
    
    PmsPlus::APNS.send_notifications([n])    
  end
  
  def disable_test_call_apns    
    PmsPlus::APNS.host = Eyedentt::Configuration[:apns_host]
    PmsPlus::APNS.port = Eyedentt::Configuration[:apns_port]
    PmsPlus::APNS.pem = Eyedentt::Configuration[:apns_cert_file]
    PmsPlus::APNS.pass = Eyedentt::Configuration[:apns_cert_pass]
    
    notified = []
        
    user = MobileUser.find(398)
    #puts user.mobile_key
    
    #title = "<font color='#A6A6A6'>PMS 관리자 이(가)</font> <font color='#000000'>[플러그인]eydentt, 커스터마이징을 위한 플러그인 개발</font> <font color='#A6A6A6'>을(를)보고하였습니다</font>"
    title = "PMSTEST"
    #msg = {:issue_id => 90881, :title => "PMS 관리자 이(가) [플러그인]eydentt, 커스터마이징을 위한 플러그인 개발 을(를)보고하였습니다"}    
    msg = {:issue_id => 90881, :title => "커스터마이징을 위한 플러그인 개발 을(를)보고하였습니다"}
    alert = title.byteslice(0, 3)    
    notified << PmsPlus::APNS::Notification.new(user.mobile_key, :alert => alert, :badge => IosNotification.badge(user.mobile_key), :sound => 'default', :other => {:issue_id => 9008801})
    #notified << PmsPlus::APNS::Notification.new(user.mobile_key, '테스트2')    
    puts notified[0].packaged_message
    
    #PmsPlus::APNS.send_notifications(notified)
  end
  
  def disable_test_deliver_ios
    PmsPlus::APNS.host = Eyedentt::Configuration[:apns_host]
    PmsPlus::APNS.port = Eyedentt::Configuration[:apns_port]
    PmsPlus::APNS.pem = Eyedentt::Configuration[:apns_cert_file]
    PmsPlus::APNS.pass = Eyedentt::Configuration[:apns_cert_pass]
          
    issue = Issue.find(90881)
    journal = Journal.find(507523)
    notified = issue.notified_watchers.select {|u| u.canMobileNotify? }    
        
    deliver_ios(notified.select { |u| u.ios? }, issue, journal)    
  end
  
  def deliver_ios(recipients, issue, journal)
    author_name = journal.user.name
    alert = 'test'
    message = "<font>test</font>"
            
    notified = []
    recipients.uniq.each do |user|
      if IosNotification.create(:user_id => user.id, :device_token => user.mobile_key, :alert => message, :issue_id => issue.id,  :created_on => Time.now)  
        notified << PmsPlus::APNS::Notification.new(user.mobile_key, :alert => alert, :badge => IosNotification.badge(user.mobile_key), :sound => 'default', :other => {:issue_id => issue.id, :journal_created_on => journal.created_on})            
      end
    end
    
    if notified.length > 0          
      #Rails.logger.debug "$$$notify pem - #{PmsPlus::APNS.pem}"
      Rails.logger.debug "$$$notify apns - #{notified.inspect}"
      PmsPlus::APNS.send_notifications(notified)
    end
  end
  
  def disable_test_deliver_android
    issue = Issue.find(90881)
    journal = Journal.find(507523)
    notified = issue.notified_watchers.select {|u| u.canMobileNotify? }
               
    if notified && notified.count > 0                
        deliver_android(notified.select { |u| u.android? }, issue, journal)        
    end        
  end
  
  def disable_test_gcm_send
    api_key = 'AIzaSyDUm46G3IGRMxD_dYVcOvcPHTqVPgzYKis'
    
    registration_ids = ["APA91bFisbnukqKTffbRuzlfIykqDDdVSgh7vPDKuBXj_6fxJSMSyuu0bigjlsclrz4tT9fSv6Pl84Cic9yeC4adaKkOQ62odM_3QyLEFrSpdIBd4oW3NobwvvE7SgMktkIc_Fe7h10x8a147mloqlU0XIZQ6i0yKQ"]
    title = 'title'
    msg = 'msg'    
   
    data = {
      :collapse_key => "#{Time.now.utc}",
      :registration_ids => registration_ids,
      :data => { :title => title, :msg => msg }
    }.to_json()   
    
    header = {      
        'Authorization' => "key=#{api_key}",
        'Content-Type' => 'application/json', #;application/x-www-form-urlencoded;charset=UTF-8
        'Content-Length' => "#{data.length}"
    }
    puts header    
    
    uri = URI.parse("https://android.googleapis.com/gcm/send")
    #uri = URI.parse("http://localhost:1926/Home/testGCM")    
    
    https = Net::HTTP.new(uri.host, uri.port)
    https.verify_mode = OpenSSL::SSL::VERIFY_NONE
    https.use_ssl = true
    https.start
        
    response = https.post(uri.path, data, header)
    puts "code: #{response.code}, message: #{response.message}, body: #{response.body}"
    
    https.finish    
  end
  
  def test_gcm_module        
    registration_ids = ["APA91bFisbnukqKTffbRuzlfIykqDDdVSgh7vPDKuBXj_6fxJSMSyuu0bigjlsclrz4tT9fSv6Pl84Cic9yeC4adaKkOQ62odM_3QyLEFrSpdIBd4oW3NobwvvE7SgMktkIc_Fe7h10x8a147mloqlU0XIZQ6i0yKQ"]
    data = { :data => { :title => 'title', :msg => 'message' } }
    
    puts Eyemine::GCM.send_notification(registration_ids, data).inspect      
  end
  
  def deliver_android(recipients, issue, journal)
    uri_android = URI(Setting.plugin_eyedentt['notification_url_android'])
    
    puts uri_android.inspect
  
    puts recipients
            
    author_name = journal.user.name
    title = 'test' 
    msg = {:issue_id => issue.id, :title => 'test'} 
    
    registration_ids = recipients.map(&:mobile_key).uniq
    puts registration_ids
    puts registration_ids.length
    
    if registration_ids.length > 0             
      res = Net::HTTP.start(uri_android.host, uri_android.port) do |http|
        req = Net::HTTP::Post.new(uri_android.path)
        req.content_type = 'application/json'                        
        req.body = ActiveSupport::JSON.encode({
          :registration_ids => registration_ids,
          :data => { :title => title, :msg => msg }
        })
                                        
        http.request(req)
      end
      puts "$$$notify gcm - code: #{res.code}, message: #{res.message}, body: #{res.body}"
    end          
  end  
  
  def disable_test_byte
    payload = "ABCDEFG"
    puts payload.bytesize
    
    puts [payload].pack("A*").bytesize
    
    puts [payload].pack("A*").byteslice(0, 10)
  end
  
  
end
