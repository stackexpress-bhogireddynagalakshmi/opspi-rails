class ChangeColumnTypeOfIspConfigUserName < ActiveRecord::Migration[6.1]
  def change
  	change_column :spree_users,:isp_config_id,:integer,null: true,default: :null
  	change_column :spree_users,:isp_config_username,:string,null: true,default: :null
  end
end
