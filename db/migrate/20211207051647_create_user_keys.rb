class CreateUserKeys < ActiveRecord::Migration[6.1]
  def change
    create_table :user_keys do |t|
      t.integer :user_id
      t.string :reseller_club_account_id
      t.text :reseller_club_account_key_enc
      t.timestamps
    end
  end
end
