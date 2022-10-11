class AddAgentIdToChatwootUser < ActiveRecord::Migration[6.1]
  def change
    add_column :chatwoot_users, :agent_id, :integer
  end
end
