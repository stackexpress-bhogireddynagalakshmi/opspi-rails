class AddIspConfigIdToSpreeUsers < ActiveRecord::Migration[6.1]
  def change
  	add_column :spree_users,:isp_config_id,:integer,:default=>true,:null=>false
  	add_column :spree_users,:isp_config_username,:string,:default=>true,:null=>false
  end
end
