class CreatePlanQuotaGroups < ActiveRecord::Migration[6.1]
  def change
    create_table :plan_quota_groups do |t|
      t.string :group_name
      t.integer :product_id
      t.integer :solid_cp_quota_group_id
      t.boolean :calculate_diskspace,:default=>true,:null=>false
      t.boolean :calculate_bandwidth,:default=>true,:null=>false
      t.boolean :enabled
      t.boolean :parent_enabled
      t.timestamps
    end
  end
end
