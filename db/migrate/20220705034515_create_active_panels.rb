class CreateActivePanels < ActiveRecord::Migration[6.1]
  def change
    create_table :active_panels do |t|
      t.string :service
      t.integer :panel_id
      t.timestamps
    end

    add_index :active_panels,[:panel_id,:service], unique: true
  end
end
