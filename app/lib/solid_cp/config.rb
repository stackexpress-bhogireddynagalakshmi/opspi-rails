module SolidCp
 	class Config
    class_attribute :username, :password, :base_url,:user_url, :register_users,:log,:timeout,:user_wsdl,:plan_wsdl,:enabled
    # Load yaml settings
    YAML.load( ERB.new( File.read( "#{Rails.root}/config/solid_cp.yml" )).result).each do |key, value|
      self.send("#{key}=", value)
    end
  end
 end