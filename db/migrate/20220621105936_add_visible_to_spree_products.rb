class AddVisibleToSpreeProducts < ActiveRecord::Migration[6.1]
  def change
    add_column :spree_products, :visible, :boolean,:default=>true,null: false
  end
end
