class CreateUserSpamFilters < ActiveRecord::Migration[6.1]
  def change
    create_table :user_spam_filters do |t|
      t.integer :user_domain_id
      t.integer :remote_spam_filter_id
      t.string  :wb
      t.string :email
      t.integer :priority
      t.boolean :active
      t.timestamps
    end
  end
end
