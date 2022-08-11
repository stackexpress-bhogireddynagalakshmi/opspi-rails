# frozen_string_literal: true

module SitePro
    class Base
      include HTTParty
      
      base_uri SitePro::Config.base_url
  
      debug_output $stdout
  
     
  
      def query(opts)
        method = opts[:method].to_s.downcase
        header = default_header
        header = header.merge(opts[:header]) if opts[:header].present?
        response = self.class.send(method, opts[:endpoint], body: opts[:body].to_json, headers: header)
        data = response.parsed_response
  
        if response.success?
          if [TrueClass, FalseClass, Integer].include?(data.class)
            data
          else
            convert_to_mash(data)
          end
        end
      end
  
      def default_header
        { 'Content-Type' => 'application/json' }
      end
  
      def authorization_header
        {"Authorization" => "Basic #{Base64::strict_encode64(SitePro::Config.username+":"+SitePro::Config.password)}"}
      end
     
  
      def convert_to_mash(data)
        case data
        when Hash
          Hashie::Mash.new(data)
        when Array
          data.map { |d| Hashie::Mash.new(d) }
        else
          data
        end
      end

      def web_server_ip(user, server_type)
        server = server_type == 'linux' ? 'web_linux' : 'web_windows'
        web_ip_key = server_type == 'linux' ? 'ISPCONFIG_WEB_SERVER_IP' : 'SOLID_CP_WEB_SERVER_IP'
        panel_id = panel_id_for(user, server)
        config_value_for(panel_id, web_ip_key)
      end
    
      def config_value_for(panel_id, key)
        value = PanelConfig.where(panel_id: panel_id, key: key).last&.value
    
        return value if value.present?
    
        raise "Value for #{key} with Panel ID #{panel_id} does not exist."
      end
    
      def panel_id_for(user,server)
        user.panel_config[server] 
      end
  
  
    end
  end
  