class AddAccountIdToPrototypeTable < ActiveRecord::Migration[6.1]
  def change
    add_column :spree_prototypes, :account_id, :integer
  end
end
