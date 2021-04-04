class CreatePackages < ActiveRecord::Migration[6.1]
  def change
    create_table :packages do |t|
      t.integer :user_id
      t.integer :solid_cp_package_id
      t.string :package_name
      t.text :package_desc
      t.timestamps
    end
  end
end
