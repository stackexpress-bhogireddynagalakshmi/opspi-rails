class AddProductIdToInvoices < ActiveRecord::Migration[6.1]
  def change
    add_column :invoices,:subscription_id,:integer
    add_column :subscriptions,:validity,:integer
  end
end
