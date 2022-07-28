class AddUserDomainIdToHostedZone < ActiveRecord::Migration[6.1]
  def change
    add_column :hosted_zones, :user_domain_id, :integer
  end
end
