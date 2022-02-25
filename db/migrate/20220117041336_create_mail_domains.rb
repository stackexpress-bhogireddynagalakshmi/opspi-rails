class CreateMailDomains < ActiveRecord::Migration[6.1]
  def change
    create_table :mail_domains do |t|
      t.integer :user_id
      t.integer :isp_config_mail_domain_id
      t.timestamps
    end
  end
end
