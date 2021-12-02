module ResellerClub
  class Config
    class_attribute :reseller_account_id,:api_key, :base_url,:user_url, :register_users,:log,:timeout,:enabled
    # Load yaml settings
    YAML.load( ERB.new( File.read( "#{Rails.root}/config/reseller_club_config.yml" )).result).each do |key, value|
      self.send("#{key}=", value)
    end
  end
 end