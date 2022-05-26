class CreateChatwootUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :chatwoot_users do |t|
      t.integer :user_id
      t.string :website_token
      t.integer :user_agent_id
      t.integer :inbox_id

      t.timestamps
    end
  end
end
