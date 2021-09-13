class AddOrderIdToInvoice < ActiveRecord::Migration[6.1]
  def change
    add_column :invoices,:order_id,:integer,after: :account_id
    add_column :spree_orders,:order_type,:integer,default: 0
  end
end
