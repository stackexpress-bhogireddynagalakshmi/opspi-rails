class CreateUserWebsites < ActiveRecord::Migration[6.1]
  def change
    create_table :user_websites do |t|
      t.integer :user_id
      t.integer :user_domain_id
      t.integer :panel_id
      t.timestamps
    end
  end
end
