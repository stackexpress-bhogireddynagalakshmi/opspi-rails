class AddAdditionalColumnsToSpreeUsers < ActiveRecord::Migration[6.1]
  def change
  	add_column :spree_users,:first_name,:string
  	add_column :spree_users,:last_name,:string
  	add_column :spree_users,:solid_cp_id,:integer
  	add_column :spree_users,:solid_cp_password,:string
  end
end
