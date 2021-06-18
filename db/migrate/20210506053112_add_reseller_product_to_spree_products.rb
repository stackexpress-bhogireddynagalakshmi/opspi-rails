class AddResellerProductToSpreeProducts < ActiveRecord::Migration[6.1]
  def change
  	add_column :spree_products,:reseller_product,:boolean,:default=>false,:null=>false
  end
end
