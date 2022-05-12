class CreateIspDatabases < ActiveRecord::Migration[6.1]
  def change
    create_table :isp_databases do |t|
      t.integer :user_id
      t.integer :isp_config_database_id

      t.timestamps
    end
  end
end
