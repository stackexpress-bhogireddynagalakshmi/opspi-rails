class AddSolidCpMasterPlanIdToProducts < ActiveRecord::Migration[6.1]
  def change
  	add_column :spree_products,:solid_cp_master_plan_id,:integer
  	add_column :packages,:solid_cp_master_plan_id,:integer
  end
end
