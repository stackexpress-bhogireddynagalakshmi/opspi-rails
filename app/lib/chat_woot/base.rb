# frozen_string_literal: true

module ChatWoot
    class Base
      include HTTParty
      
      base_uri ChatWoot::Config.base_url
  
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
  
      def authorization_user_header
        {"api_access_token" => ChatWoot::Config.api_access_token}
      end

      def authorization_platform_header
        {"api_access_token" => ChatWoot::Config.platform_api_key}
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
  
  
    end
  end
  