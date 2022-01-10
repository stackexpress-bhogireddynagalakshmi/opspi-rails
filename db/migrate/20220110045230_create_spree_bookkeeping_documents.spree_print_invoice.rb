# This migration comes from spree_print_invoice (originally 20150616133616)
class CreateSpreeBookkeepingDocuments < SpreeExtension::Migration[4.2]
  def change
    create_table :spree_bookkeeping_documents do |t|
      t.references :printable, polymorphic: true
      t.string :template
      t.string :number
      t.string :firstname
      t.string :lastname
      t.string :email
      t.decimal :total, precision: 12, scale: 2

      t.timestamps null: false
    end
  end
end
