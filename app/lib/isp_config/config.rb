# frozen_string_literal: true

module IspConfig
  # ISP Configuration Provider
  class Config
    extend PanelConfiguration
    class_attribute :username, :password, :base_url, :user_url, :register_users, :log, :timeout, :enabled
    # Load yaml settings
    YAML.safe_load(ERB.new(File.read("#{Rails.root}/config/isp_config.yml")).result).each do |key, value|
      send("#{key}=", value)
    end

    USERNAME_KEY  = "ISP_CONFIG_USERNAME"
    PASSWORD_KEY  = "ISP_CONFIG_PASSWORD"
    URL_KEY       = "ISP_CONFIG_REMOTE_URL"
    SERVER_TYPE   = "web_linux"
    WEB_SERVER_IP_KEY  = "ISPCONFIG_WEB_SERVER_IP"

    def self.username_key
      USERNAME_KEY
    end

    def self.password_key
      PASSWORD_KEY
    end

    def self.url_key
      URL_KEY
    end

    def self.web_server_ip_key 
      WEB_SERVER_IP_KEY
    end

    def self.server_type_key
      SERVER_TYPE
    end
  end
end
