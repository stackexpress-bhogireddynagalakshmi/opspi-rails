class RemoveHostedZoneIdColumnFromUserDomains < ActiveRecord::Migration[6.1]
  def self.up
    remove_column :user_domains,:hosted_zone_id
  end

  def self.down
    add_column :user_domains,:hosted_zone_id, :integer
  end
end
