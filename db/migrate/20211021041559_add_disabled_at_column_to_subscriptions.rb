class AddDisabledAtColumnToSubscriptions < ActiveRecord::Migration[6.1]
  def change
    add_column :subscriptions,:panel_disabled_at,:datetime
  end

end
