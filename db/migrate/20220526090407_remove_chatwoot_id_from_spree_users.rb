class RemoveChatwootIdFromSpreeUsers < ActiveRecord::Migration[6.1]
  def change
    remove_column :spree_users, :chatwoot_id, :integer
  end
end
