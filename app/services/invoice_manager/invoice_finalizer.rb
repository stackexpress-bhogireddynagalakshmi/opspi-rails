module InvoiceManager
  class InvoiceFinalizer < ApplicationService
    
    attr_reader :invoice, :account, :account_balance

    def initialize(invoice)
      @invoice = invoice
      @account = invoice.account
    end


    def call

    end

    def finalize_transactional_actions
      account.with_lock do
       invoice.finalize!
      end
    end

    def try_finalize
      tagged_message = 'InvoiceFinalizer::try_finalize'

      original_invoice = @invoice
      @invoice = Marshal.load(Marshal.dump(original_invoice))

      Rails.logger.tagged(tagged_message) do
        Invoice.transaction(requires_new: true) do
          finalize_transactional_actions
          raise ActiveRecord::Rollback
        end
      end
    rescue => e
      Rails.logger.info("[#{tagged_message}] Can't finalize! invoice #{invoice.id}. Error: #{e.message}")
      return false
    else
      Rails.logger.info("[#{tagged_message}] Can finalize! invoice #{invoice.id}.")
      return true
    ensure
      # Ensure the original invoice is restored to the instance variable
      @invoice = original_invoice
    end
    
  end
end