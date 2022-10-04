class AddBackupColumnToUserWebsite < ActiveRecord::Migration[6.1]
  def change
    add_column :user_websites, :enable_backup, :boolean, default: false, null: false
  end
end
