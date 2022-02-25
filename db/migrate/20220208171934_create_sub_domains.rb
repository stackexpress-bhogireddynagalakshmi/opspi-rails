class CreateSubDomains < ActiveRecord::Migration[6.1]
  def change
    create_table :sub_domains do |t|
      t.integer :user_id
      t.integer :isp_config_sub_domain_id
      t.timestamps
    end
  end
end
