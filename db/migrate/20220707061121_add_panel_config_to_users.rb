class AddPanelConfigToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :spree_users, :panel_config, :json

   
  end
end

