class CreateUserMailingLists < ActiveRecord::Migration[6.1]
  def change
    create_table :user_mailing_lists do |t|
      t.integer :user_domain_id
      t.string  :listname
      t.string  :email
      t.integer :remote_mailing_list_id
      t.timestamps
    end
  end
end
