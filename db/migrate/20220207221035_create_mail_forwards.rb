class CreateMailForwards < ActiveRecord::Migration[6.1]
  def change
    create_table :mail_forwards do |t|
      t.integer :user_id
      t.integer :isp_config_mail_forward_id
      t.timestamps
    end
  end
end
