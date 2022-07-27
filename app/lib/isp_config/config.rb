# frozen_string_literal: true

module IspConfig
  class Config
    class_attribute :username, :password, :base_url, :user_url, :register_users, :log, :timeout, :enabled
    # Load yaml settings
    YAML.safe_load(ERB.new(File.read("#{Rails.root}/config/isp_config.yml")).result).each do |key, value|
      send("#{key}=", value)
    end

    def self.api_username(user)
      panel_id = panel_id_for(user)
      config_value_for(panel_id, 'ISP_CONFIG_USERNAME')
    end

    def self.api_password(user)
      panel_id = panel_id_for(user)
      config_value_for(panel_id, 'ISP_CONFIG_PASSWORD')
    end

    def self.api_url(panel_id)
      config_value_for(panel_id,'ISP_CONFIG_REMOTE_URL')
    end

    def self.config_value_for(panel_id, key)
      value = PanelConfig.where(panel_id: panel_id, key: key).last&.value

      return value if value.present?

      raise "Value for #{key} with Panel ID #{panel_id} does not exist."
    end

    def self.panel_id_for(user)
      user.panel_config["web_linux"] 
    end
  end
end
