class CreateUserMailForwards < ActiveRecord::Migration[6.1]
  def change
    create_table :user_mail_forwards do |t|
      t.integer :user_domain_id
      t.integer :remote_mail_forward_id
      t.string  :source
      t.text    :destination
      t.boolean :active
      t.boolean :allow_send_as
      t.boolean :greylisting
      t.timestamps
    end
  end
end
