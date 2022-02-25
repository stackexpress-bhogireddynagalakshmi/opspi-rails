class CreateHostedZoneRecord < ActiveRecord::Migration[6.1]
  def change
    create_table :hosted_zone_records do |t|
      t.integer :hoste_zone_id
      t.string :record_name
      t.string :record_type
      t.string :value
      t.string :ttl
      t.integer :isp_config_host_zone_record_id
      t.string :status

      t.timestamps
    end
  end
end
