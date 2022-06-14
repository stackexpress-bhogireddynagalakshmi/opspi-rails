class AddHsphereClusterId < ActiveRecord::Migration[6.1]
  def change
    add_column :spree_users,:hsphere_cluster_id,:integer
  end
end
