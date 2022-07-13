class CreatePanels < ActiveRecord::Migration[6.1]
  def change
    create_table :panels do |t|
      t.integer  :panel_type_id
      t.string   :name
      t.timestamps
    end
  end
end
