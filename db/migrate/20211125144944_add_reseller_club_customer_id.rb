class AddResellerClubCustomerId < ActiveRecord::Migration[6.1]
  def change
    add_column :spree_users,:reseller_club_customer_id,:integer
    add_column :spree_users,:reseller_club_contact_id,:integer
  end
end
