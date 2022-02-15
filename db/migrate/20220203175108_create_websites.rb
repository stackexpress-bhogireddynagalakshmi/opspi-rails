class CreateWebsites < ActiveRecord::Migration[6.1]
  def change
    create_table :websites do |t|
      t.integer :user_id
      t.integer :isp_config_website_id
      t.timestamps
    end
  end
end
