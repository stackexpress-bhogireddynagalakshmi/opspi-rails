class AddChatwootIdToSpreeUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :spree_users, :chatwoot_id, :integer
  end
end
