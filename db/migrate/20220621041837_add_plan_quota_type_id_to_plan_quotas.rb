class AddPlanQuotaTypeIdToPlanQuotas < ActiveRecord::Migration[6.1]
  def change
    add_column :plan_quotas, :quota_type_id, :integer
  end
end
