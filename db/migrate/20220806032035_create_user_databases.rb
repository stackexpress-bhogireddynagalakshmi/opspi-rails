class CreateUserDatabases < ActiveRecord::Migration[6.1]
  def change
    create_table :user_databases do |t|
      t.integer :user_id
      t.string  :database_name
      t.string  :database_user
      t.integer :database_type
      t.integer :database_id
      t.timestamps
    end
  end
end
