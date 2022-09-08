class AddStoreIdToProductConfigs < ActiveRecord::Migration[6.1]
  def change
    add_column :product_configs, :store_id, :integer
  end
end
