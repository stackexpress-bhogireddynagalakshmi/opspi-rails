# frozen_string_literal: true

module IspConfig
  class Config
    class_attribute :username, :password, :base_url, :user_url, :register_users, :log, :timeout, :enabled
    # Load yaml settings
    YAML.safe_load(ERB.new(File.read("#{Rails.root}/config/isp_config.yml")).result).each do |key, value|
      send("#{key}=", value)
    end
  end
end
