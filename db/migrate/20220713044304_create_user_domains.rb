class CreateUserDomains < ActiveRecord::Migration[6.1]
  def change
    create_table :user_domains do |t|
      t.integer :user_id
      t.string :domain
      t.integer :web_hosting_type
      t.integer :hosted_zone_id
      t.boolean :success
      t.timestamps
    end
  end
end
