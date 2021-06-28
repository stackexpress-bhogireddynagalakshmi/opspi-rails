class AddAccessColumnToSpreeStores < ActiveRecord::Migration[6.1]
  def change
  	add_column :spree_stores,:solid_cp_access,:boolean,:default=>false,if_not_exists: true
  	add_column :spree_stores,:isp_config_access,:boolean,:default=>false,if_not_exists: true

  	Spree::Store.all.each do |store|
  		store.update_column :solid_cp_access, store.account&.solid_cp_access 
  		store.update_column :isp_config_access, store.account&.isp_config_access
  	end
  	
  end
end
