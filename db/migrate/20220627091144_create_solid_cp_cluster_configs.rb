class CreateSolidCpClusterConfigs < ActiveRecord::Migration[6.1]
  def change
    create_table :solid_cp_cluster_configs do |t|
      t.string :key
      t.string :value
      t.integer :cluster_id

      t.timestamps
    end
  end
end
