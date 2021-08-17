module InvoiceManager
  class InvoiceOpener < ApplicationService
     def ensure_open_invoice_for(user, billing_period)
      
      invoice = user.invoices.
            where(status: 'active',
                  account_id: account_id, 
                  started_on: billing_period.begin,
                  finished_on: billing_period.end).
            first_or_initialize(account:    user.account,
                                started_on:  billing_period.begin,
                                finished_on: billing_period.end)

    end

  end
end