class CreateInvoices < ActiveRecord::Migration[6.1]
  def change
    create_table :invoices do |t|
      t.string   :name
      t.integer  :account_id
      t.integer  :user_id
      t.date     :started_on
      t.date     :finished_on
      t.string   :status
      t.string   :invoice_number
      t.datetime :finalized_at
      t.boolean  :tweak
      t.boolean  :pdf_url_generated
      t.datetime :processing_started_on
      t.datetime :due_date
      t.datetime :closed_at
      t.decimal  :balance,  precision: 14, scale: 4
      t.integer  :net_term_days
      t.timestamps
    end
  end
end
