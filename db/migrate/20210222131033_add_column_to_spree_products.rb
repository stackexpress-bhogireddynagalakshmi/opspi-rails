class AddColumnToSpreeProducts < ActiveRecord::Migration[6.1]
  
  def change
  	 add_column :spree_products, :account_id, :integer
  	 add_column :spree_users, :account_id, :integer
  	 add_column :spree_orders, :account_id,:integer
  	 add_column :spree_stores, :admin_email, :string
  	 add_column :spree_stores, :account_id, :integer

  	 add_column :accounts,:domain,:string
  	 add_column :accounts,:subdomain,:string
  end

end
