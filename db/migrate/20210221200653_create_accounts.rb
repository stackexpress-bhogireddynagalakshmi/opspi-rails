class CreateAccounts < ActiveRecord::Migration[6.1]
  def change
    create_table :accounts do |t|
      t.string :orgainization_name
      t.integer :store_id
      t.string :account_type
      t.timestamps
    end
  end
end
