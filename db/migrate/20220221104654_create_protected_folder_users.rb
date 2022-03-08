class CreateProtectedFolderUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :protected_folder_users do |t|
      t.integer :user_id
      t.integer :isp_config_protected_folder_user_id
      t.timestamps
    end
  end
end
