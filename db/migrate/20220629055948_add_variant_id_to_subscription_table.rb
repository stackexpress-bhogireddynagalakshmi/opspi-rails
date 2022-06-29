class AddVariantIdToSubscriptionTable < ActiveRecord::Migration[6.1]
  def change
    add_column :subscriptions, :variant_id, :integer
  end
end
