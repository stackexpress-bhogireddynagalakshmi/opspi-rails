class AddResellerSignupToSpreeUsers < ActiveRecord::Migration[6.1]
  def change
  	add_column :spree_users,:reseller_signup,:boolean,:default=>false,:null=>false
  end
end
