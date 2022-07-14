class CreatePanelConfigs < ActiveRecord::Migration[6.1]
  def change
    create_table :panel_configs do |t|
      t.integer :panel_id
      t.string  :key
      t.string  :value

      t.timestamps
    end

    add_index :panel_configs,[:panel_id,:key], unique: true
  end
end
