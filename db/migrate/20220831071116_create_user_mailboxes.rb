class CreateUserMailboxes < ActiveRecord::Migration[6.1]
  def change
    create_table :user_mailboxes do |t|
      t.integer :user_domain_id
      t.integer :remote_mailbox_id
      t.string :name
      t.string :email
      t.integer :quota
      t.text :cc
      t.boolean :forward_in_lda
      t.boolean :policy
      t.boolean :postfix
      t.boolean :disablesmtp
      t.boolean :disabledeliver
      t.boolean :greylisting
      t.boolean :disableimap
      t.boolean :disablepop3
      t.timestamps
    end


  end
end
