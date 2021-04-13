class AddSolidCpPlanIdToStore < ActiveRecord::Migration[6.1]
  def change
  	add_column :spree_stores,:solid_cp_master_plan_id,:integer
  end
end
