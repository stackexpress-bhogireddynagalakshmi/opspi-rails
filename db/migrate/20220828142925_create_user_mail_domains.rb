class CreateUserMailDomains < ActiveRecord::Migration[6.1]
  def change
    create_table :user_mail_domains do |t|
      t.integer :user_domain_id
      t.integer :remote_mail_domain_id
      t.timestamps
    end
  end
end
