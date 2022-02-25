class CreateMailUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :mail_users do |t|
      t.integer :user_id
      t.integer :isp_config_mailuser_id
      t.timestamps
    end
  end
end
