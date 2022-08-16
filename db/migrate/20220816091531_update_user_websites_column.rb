class UpdateUserWebsitesColumn < ActiveRecord::Migration[6.1]
  def up
    rename_column :user_websites, :website_id, :remote_website_id
    remove_column :user_websites, :user_id
    remove_column :user_websites, :panel_id

    add_column :user_websites, :hosting_type, :integer
  end

  def down
    remove_column :user_websites, :hosting_type

    rename_column :user_websites, :remote_website_id, :website_id
    add_column :user_websites, :user_id, :integer
    add_column :user_websites, :panel_id, :integer
  end
end
