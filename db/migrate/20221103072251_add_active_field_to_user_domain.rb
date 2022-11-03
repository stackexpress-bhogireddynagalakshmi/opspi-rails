class AddActiveFieldToUserDomain < ActiveRecord::Migration[6.1]
  def change
  	add_column :user_domains, :active, :boolean, default: true
  end
end
