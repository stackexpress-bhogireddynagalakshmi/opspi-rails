class AddSolidCpAndIspConfigFieldsToAccount < ActiveRecord::Migration[6.1]
  def change
  	add_column :accounts,:solid_cp_access,:boolean
  	add_column :accounts,:isp_config_access,:boolean
  end
end
