class AddServerTypeToSpreeProducts < ActiveRecord::Migration[6.1]
  def change
  	add_column :spree_products,:server_type,:integer
  end
end