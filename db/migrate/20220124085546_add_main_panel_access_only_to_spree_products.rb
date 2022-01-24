class AddMainPanelAccessOnlyToSpreeProducts < ActiveRecord::Migration[6.1]
  def change
    add_column :spree_products, :main_panel_access_only, :boolean,:default=>false
  end
end
