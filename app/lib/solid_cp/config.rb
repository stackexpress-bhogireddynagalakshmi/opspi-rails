# frozen_string_literal: true

module SolidCp
  # SolidCp Configuration Provder class
  class Config
    extend PanelConfiguration

    class_attribute :username, :password, :base_url, :user_url, :register_users, :log, :timeout, :user_wsdl, :plan_wsdl,
                    :enabled
    # Load yaml settings
    YAML.safe_load(ERB.new(File.read("#{Rails.root}/config/solid_cp.yml")).result).each do |key, value|
      send("#{key}=", value)
    end

    USERNAME_KEY  = "SOLID_CP_USERNAME"
    PASSWORD_KEY  = "SOLID_CP_PASSWORD"
    URL_KEY       = "SOLID_CP_REMOTE_URL"
    SERVER_TYPE   = "web_windows"

    def self.username_key
      USERNAME_KEY
    end

    def self.password_key
      PASSWORD_KEY
    end

    def self.url_key
      URL_KEY
    end

    def self.server_type_key
      SERVER_TYPE
    end
  end
end
