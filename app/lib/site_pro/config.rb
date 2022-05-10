# frozen_string_literal: true
module SitePro
    class Config
      class_attribute :base_url, :username, :password, :api_url
      # Load yaml settings
      YAML.safe_load(ERB.new(File.read("#{Rails.root}/config/site_builder.yml")).result).each do |key, value|
        send("#{key}=", value)
      end
    end
  end
  