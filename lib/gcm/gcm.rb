module Eyemine
  module GCM
  
    #@uri = URI.parse("http://localhost:1926/Home/testGCM")
    @uri = URI.parse("https://android.googleapis.com/gcm/send")        
    @api_key = 'AIzaSyDUm46G3IGRMxD_dYVcOvcPHTqVPgzYKis'
  
    class << self
      attr_accessor :uri, :api_key
    end
  
    def self.send_notification(registration_ids, options = {})      
      payload = { :registration_ids => registration_ids, :collapse_key => "#{Time.now.utc}" }.merge(options).to_json
      
      header = {
          'Authorization' => "key=#{self.api_key}",
          'Content-Type' => 'application/json', #;application/x-www-form-urlencoded;charset=UTF-8
          'Content-Length' => "#{payload.length}"
      }
      
      https = Net::HTTP.new(self.uri.host, self.uri.port)
      https.verify_mode = OpenSSL::SSL::VERIFY_NONE
      https.use_ssl = true
      https.start      
      response = https.post(self.uri.path, payload, header)
      https.finish
            
      return self.build_response(response)
    end
        
    def self.build_response(response)
      return case response.code.to_i
              when 200
                body = response.body || {}
                { :response => 'success', :body => body, :status_code => response.code }
              when 400
                { :response => 'Only applies for JSON requests. Indicates that the request could not be parsed as JSON, or it contained invalid fields.', :status_code => response.code }
              when 401
                { :response => 'There was an error authenticating the sender account.', :status_code => response.code }
              when 500
                { :response => 'There was an internal error in the GCM server while trying to process the request.', :status_code => response.code }
              when 503
                { :response => 'Server is temporarily unavailable.', :status_code => response.code }
            end
    end
  
  end
end  