module SolidCp
 	class Config
    class_attribute :username, :password, :base_url, :register_users,:log,:timeout
    # Load yaml settings
    YAML.load( ERB.new( File.read( "#{Rails.root}/config/solid_cp.yml" )).result)[Rails.env].each do |key, value|
      self.send("#{key}=", value)
    end
  end
 end