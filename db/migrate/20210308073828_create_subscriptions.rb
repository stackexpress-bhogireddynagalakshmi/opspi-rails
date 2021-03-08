class CreateSubscriptions < ActiveRecord::Migration[6.1]
  def change
    create_table :subscriptions do |t|
      t.integer :product_id
      t.integer :user_id
      t.date :start_date
      t.date :end_date
      t.decimal :price, precision: 8, scale: 2
      t.boolean :status
      t.date :canceled_at
      t.string :frequency
      t.timestamps
    end
  end
end
