# frozen_string_literal: true

module ResellerClub
  class Config
    class_attribute :reseller_account_id, :api_key, :base_url, :user_url, :register_users, :log, :timeout, :enabled
    # Load yaml settings
    YAML.safe_load(ERB.new(File.read("#{Rails.root}/config/reseller_club_config.yml")).result).each do |key, value|
      send("#{key}=", value)
    end
  end
end
