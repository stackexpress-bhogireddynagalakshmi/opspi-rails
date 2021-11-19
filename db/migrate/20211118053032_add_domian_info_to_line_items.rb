class AddDomianInfoToLineItems < ActiveRecord::Migration[6.1]
  def change
    add_column :spree_line_items,:domain,:string
    add_column :spree_line_items,:validity,:integer
    add_column :spree_line_items,:protect_privacy,:boolean
  end
end
