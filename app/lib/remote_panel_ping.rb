require 'openssl'
require "savon"

class RemotePanelPing 
  OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

  include PanelConfiguration

  def initialize(panel_id)
    @panel = Panel.find(panel_id) 
  end

  def call
    case @panel.panel_type.name

    when "ispconfig"
      ping_isp_config
    when "solidcp"
      ping_solid_cp
    else
      raise 'Unknow Panel Type'
    end
  end

  def ping_isp_config
    username = config_value_for(@panel.id, IspConfig::Config::USERNAME_KEY)
    password = config_value_for(@panel.id, IspConfig::Config::PASSWORD_KEY)
    url      =  "#{IspConfig::Config.api_url(@panel.id)}/json.php?login"

    @result = HTTParty.post(url, 
    body: {
                username: username,
                password:password + "111"
              }.to_json,
    headers:{ 'Content-Type' => 'application/json' } )

    if @result.success?
      { success: true, message: "#{@panel.abbr} is responding"}
    else
      { success: false, message: "#{@panel.abbr} is not responding"}
    end

  end


  def ping_solid_cp
    base_url = SolidCp::Config.api_url(@panel.id)
    wsdl_url = "#{base_url}#{SolidCp::Base::SOAP_USER_WSDL}"
    @client = Savon.client(wsdl: wsdl_url)

    begin
      if @client.operations.size > 0
        { success: true, message: "#{@panel.abbr} is responding"}
      else
        { success: false, message: "#{@panel.abbr} is not responding"}
      end
      
    rescue Exception => e
       Rails.logger.error {e.backtrace }
       { success: false, message: "#{@panel.abbr} is not responding"}      
    end
  end
end

