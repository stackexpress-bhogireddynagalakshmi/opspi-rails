class AddAccessColumnToSpreeStores < ActiveRecord::Migration[6.1]
  def change
  	add_column :spree_stores,:solid_cp_access,:boolean,:default=>false,null: false,if_not_exists: true
  	add_column :spree_stores,:isp_config_access,:boolean,:default=>false,null: false,if_not_exists: true

  	Spree::Store.all.each do |store|
  		store.solid_cp_access = store.account.solid_cp_access rescue false
  		store.isp_config_access = store.account.isp_config_access rescue false
  		puts store.save
  	end
  end
end
