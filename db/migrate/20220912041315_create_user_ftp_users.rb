class CreateUserFtpUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :user_ftp_users do |t|

      t.integer :user_domain_id
      t.integer :remote_ftp_user_id
      t.string  :username
      t.string  :dir
      t.boolean :active    
      t.timestamps
    end
  end
end
