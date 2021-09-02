class AddColumnPlanValidityToProducts < ActiveRecord::Migration[6.1]
  def change
    add_column :spree_products,:validity,:integer
    add_column :spree_products,:frequency,:integer
  end
end
