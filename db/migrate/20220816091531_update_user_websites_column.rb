class UpdateUserWebsitesColumn < ActiveRecord::Migration[6.1]
  def up
    add_column :user_websites, :remote_website_id, :integer
    add_column :user_websites, :hosting_type, :integer
    
    remove_column :user_websites, :user_id
    remove_column :user_websites, :panel_id

   
  end

  def down
    remove_column :user_websites, :hosting_type
    remove_column :user_websites, :remote_website_id
    
    add_column :user_websites, :user_id, :integer
    add_column :user_websites, :panel_id, :integer
  end
end
