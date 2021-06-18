class AddSolidCpGroupIdToPlanQuotas < ActiveRecord::Migration[6.1]
  def change
  	add_column :plan_quotas,:solid_cp_quota_group_id,:integer,:after=>:plan_quota_group_id
  end
end
