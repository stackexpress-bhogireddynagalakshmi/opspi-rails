class ChangeUsersIspConfigUsernameDefaultValue < ActiveRecord::Migration[6.1]
  def self.up
    Spree::User.where(isp_config_username: 'null').update(isp_config_username: nil)
    
    change_column :spree_users,:isp_config_username,:string,default: nil
  end

  def self.down

  end

end
