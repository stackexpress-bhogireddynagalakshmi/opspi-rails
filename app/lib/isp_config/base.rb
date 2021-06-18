module IspConfig
  class Base

    include HTTParty
    # base_uri ''
    base_uri IspConfig::Config:: base_url

    debug_output $stdout

    attr_accessor :user

    default_options.update(verify: false)

    cattr_accessor :current_session_token, :current_session_started

    def query opts
      method   = opts[:method].to_s.downcase
      header = default_header
      header = header.merge(opts[:header])  if opts[:header].present? 
      set_session_id opts[:body]
      response = self.class.send(method, opts[:endpoint],body: opts[:body].to_json,:headers => header)
      data = response.parsed_response

      if response.success?
        if [ TrueClass, FalseClass, Fixnum ].include?(data.class)
          data
        else
          convert_to_mash(data)
        end
      else
        nil
      end
    end

 
    def default_header
    	{ 'Content-Type' => 'application/json'}
    end

   def set_session_id body
   	 isp_config_session_token
   	 body[:session_id] = self.current_session_token
   	 body
   end

    
    def convert_to_mash data
      if data.is_a? Hash
        Hashie::Mash.new(data)
      elsif data.is_a? Array
        data.map { |d| Hashie::Mash.new(d) }
      else
        data
      end
    end


    def isp_config_session_token
      fresh_token? ? current_session_token : login_app
    end

    def fresh_token?
       current_session_token && current_session_started && current_session_started >= 90.minutes.ago
    end


    def login_app
      puts "Login to ISP Config"
      login_hash = {
        :endpoint => '/json.php?login',
        :method => :POST,
        :body => {
          :username=>IspConfig::Config.username,
          :password=>IspConfig::Config.password
        }
      }
      method   = login_hash[:method].to_s.downcase
      response = self.class.send(method, login_hash[:endpoint],body: login_hash[:body].to_json)
      self.current_session_started = Time.zone.now       
      self.current_session_token = response.parsed_response["response"]
    end
    

  end

end

