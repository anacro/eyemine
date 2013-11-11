module Eyemine
  module Configuration
    @config = nil
    
    class << self
      
      def load()
        raw_config = File.read(Rails.root.join("plugins/eyemine/config", "configuration.yml"))
        parsed_config = ERB.new(raw_config).result        
        @config = YAML.load(parsed_config)[Rails.env].symbolize_keys      
      end

      def [](name)
        load unless @config
        @config[name]
      end      
    
    end
    
  end
end

#Rails.logger.debug "$$$debug - #{Eyemine::Configuration[:apns_cert_file]}"