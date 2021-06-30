class AddAccountIdToSpreePaymentMethods < ActiveRecord::Migration[6.1]
  def change
  	add_column :spree_payment_methods,:account_id,:integer
  end
end
