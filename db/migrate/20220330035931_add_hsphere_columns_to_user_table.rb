class AddHsphereColumnsToUserTable < ActiveRecord::Migration[6.1]
  def change
    add_column :spree_users, :hsphere_user_id, :integer
    add_column :spree_users, :hsphere_account_id, :integer
  end
end
