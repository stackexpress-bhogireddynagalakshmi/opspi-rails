class AddPlansColumnToSpreeProducts < ActiveRecord::Migration[6.1]
  def change
  	add_column :spree_products,:plan_type,:string
  	add_column :spree_products,:no_of_website,:integer
  	add_column :spree_products,:storage,:integer
  	add_column :spree_products,:ssl_support,:boolean,:default=>false,:null=>false
  	add_column :spree_products, :domain,:integer
  	add_column :spree_products, :subdomain,:integer
  	add_column :spree_products,:parked_domain,:integer
  	add_column :spree_products, :mailbox,:integer
  	add_column :spree_products, :auto_daily_malware_scan,:boolean,:default=>false,:null=>false
  	add_column :spree_products,:email_order_confirmation,:boolean,:default=>true,:null=>false
  end
end
