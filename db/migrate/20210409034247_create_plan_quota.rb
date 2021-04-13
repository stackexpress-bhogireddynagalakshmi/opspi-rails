class CreatePlanQuota < ActiveRecord::Migration[6.1]
  def change
    create_table :plan_quotas do |t|
      t.string  :quota_name
      t.integer :plan_quota_group_id
      t.integer :solid_cp_quota_id
      t.integer :quota_value
      t.boolean :parent_quota_value
      t.boolean :unlimited ,:default=>false,:null=>false
      t.boolean :enabled
      t.timestamps
    end
  end
end
