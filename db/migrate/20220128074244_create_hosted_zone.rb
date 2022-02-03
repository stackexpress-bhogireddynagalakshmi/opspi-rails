class CreateHostedZone < ActiveRecord::Migration[6.1]
  def change
    create_table :hosted_zones do |t|
      t.integer :user_id
      t.string :name
      t.integer :isp_config_host_zone_id
      t.string :status

      t.timestamps
    end
  end
end
