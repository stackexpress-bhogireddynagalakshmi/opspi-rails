class CreateProtectedFolders < ActiveRecord::Migration[6.1]
  def change
    create_table :protected_folders do |t|
      t.integer :user_id
      t.integer :isp_config_protected_folder_id
      t.timestamps
    end
  end
end
