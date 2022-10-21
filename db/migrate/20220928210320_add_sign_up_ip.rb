class AddSignUpIp < ActiveRecord::Migration[6.1]
  def change
    add_column :spree_users,:sign_up_ip,:string
  end
end
