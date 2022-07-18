class AddColumnToUserDomains < ActiveRecord::Migration[6.1]
  def change
    add_column :user_domains, :panel_id, :integer
  end
end