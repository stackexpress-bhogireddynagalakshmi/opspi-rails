class AddStatusToUserDatabases < ActiveRecord::Migration[6.1]
  def change
    add_column :user_databases, :status, :integer
  end
end
