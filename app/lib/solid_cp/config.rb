# frozen_string_literal: true

module SolidCp
  class Config
    class_attribute :username, :password, :base_url, :user_url, :register_users, :log, :timeout, :user_wsdl, :plan_wsdl,
                    :enabled
    # Load yaml settings
    YAML.safe_load(ERB.new(File.read("#{Rails.root}/config/solid_cp.yml")).result).each do |key, value|
      send("#{key}=", value)
    end
  end
end
