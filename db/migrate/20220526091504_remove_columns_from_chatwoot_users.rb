class RemoveColumnsFromChatwootUsers < ActiveRecord::Migration[6.1]
  def change
    remove_column :chatwoot_users, :user_id, :integer
    remove_column :chatwoot_users, :user_agent_id, :integer
  end
end
