module IspConfig
 	class Config
    class_attribute :username, :password, :base_url,:user_url, :register_users,:log,:timeout
    # Load yaml settings
    YAML.load( ERB.new( File.read( "#{Rails.root}/config/isp_config.yml" )).result).each do |key, value|
      self.send("#{key}=", value)
    end
  end
 end