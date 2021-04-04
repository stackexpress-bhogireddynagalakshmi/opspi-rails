class AddSolidCpPlanIdToProducts < ActiveRecord::Migration[6.1]
  def change
  	add_column :spree_products,:solid_cp_plan_id,:integer
  end
end
