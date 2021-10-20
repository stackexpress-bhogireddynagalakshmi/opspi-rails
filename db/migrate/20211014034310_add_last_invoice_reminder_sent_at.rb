class AddLastInvoiceReminderSentAt < ActiveRecord::Migration[6.1]
  def change
    add_column :invoices,:last_reminder_sent_at,:datetime
  end
end
