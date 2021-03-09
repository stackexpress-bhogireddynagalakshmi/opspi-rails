class AddSubscribableToProducts < ActiveRecord::Migration[6.1]
  def change
  	add_column :spree_products,:subscribable,:boolean,:default=>false,null: false
  end
end
