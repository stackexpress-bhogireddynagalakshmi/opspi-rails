class AddIspConfigMasterTemplateIdToStores < ActiveRecord::Migration[6.1]
  def change
  	add_column :spree_stores,:isp_config_master_template_id,:integer
  	add_column :spree_products,:isp_config_master_template_id,:integer
  	Spree::Product.all.where(:account_id=>nil).update(:account_id=>1)
  end
end
