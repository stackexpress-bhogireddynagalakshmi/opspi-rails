class ChangeColumnTypeSpreeOrdersLastIpAddress < ActiveRecord::Migration[6.1]
  def self.up
    change_column :spree_orders, :last_ip_address, :text
  end

  def self.down
  end
end
