class CreateProductConfigs < ActiveRecord::Migration[6.1]
  def change
    create_table :product_configs do |t|
      t.string :name
      t.integer :product_id
      t.json :configs
      t.string :product_type
      t.string :status

      t.timestamps
    end
  end
end
