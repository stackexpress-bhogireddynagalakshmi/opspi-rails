class AddStoreAccountIdToChatwootUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :chatwoot_users, :store_account_id, :integer
  end
end
