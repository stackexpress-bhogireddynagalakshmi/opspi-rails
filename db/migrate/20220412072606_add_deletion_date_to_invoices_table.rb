class AddDeletionDateToInvoicesTable < ActiveRecord::Migration[6.1]
  def change
    add_column :invoices, :deletion_date, :date
    add_column :invoices, :suspension_date, :date    
  end
end
