# frozen_string_literal: true
module ChatWoot
    class Config
      class_attribute :base_url, :api_access_token, :account_id, :platform_api_key
      # Load yaml settings
      YAML.safe_load(ERB.new(File.read("#{Rails.root}/config/chat_woot.yml")).result).each do |key, value|
        send("#{key}=", value)
      end
    end
  end
  