class CreateQuotaUsages < ActiveRecord::Migration[6.1]
  def change
    create_table :quota_usages do |t|
      t.integer :user_id
      t.integer :product_id
      t.json :quota_used

      t.timestamps
    end
  end
end
