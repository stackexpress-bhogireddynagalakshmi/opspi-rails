class CreateFtpUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :ftp_users do |t|
      t.integer :user_id
      t.integer :isp_config_ftp_user_id
      t.timestamps
    end
  end
end
