class CreateMailingLists < ActiveRecord::Migration[6.1]
  def change
    create_table :mailing_lists do |t|
      t.integer :user_id
      t.integer :isp_config_mailing_list_id
      t.timestamps
    end
  end
end
