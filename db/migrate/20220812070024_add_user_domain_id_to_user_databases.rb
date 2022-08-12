class AddUserDomainIdToUserDatabases < ActiveRecord::Migration[6.1]
  def change
    add_column :user_databases, :user_domain_id, :integer
  end
end
