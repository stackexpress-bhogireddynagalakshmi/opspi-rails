class CreateTenantServices < ActiveRecord::Migration[6.1]
  def change
    create_table :tenant_services do |t|
      t.integer :user_id
      t.integer :account_id
      t.integer :store_id
      t.boolean :service_executed,:default=>false,:null=>false
      t.timestamps
    end
  end
end

