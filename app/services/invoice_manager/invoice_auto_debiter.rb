module InvoiceManager
  class InvoiceAutoDebiter < ApplicationService
    attr_reader :invoice,:payment_source

    def initialize(invoice,options={})
      @invoice = invoice
      Rails.logger.info { "Finding default payment source"}

      @payment_source = invoice.user.payment_sources.detect{|x|x.default?} if invoice.present?
      Rails.logger.info { "Payment Source Found: #{@payment_source.present?}"}
    end

    def call

      return nil unless invoice.present?
      return nil unless invoice.active?
      return nil unless payment_source.present?
        
      Rails.logger.info { "Finding or Creating order by invoice #{invoice.invoice_number}" }
      @order = InvoiceManager::OrderCreator.new(invoice).call #Issue
  
      @order.next

      Rails.logger.info { "Creating payment object for an order"}
      payment = @order.payments.create(payment_attributes)

      Rails.logger.info { "Attempting to authorize a payment"}

      if payment.authorize!     
        Rails.logger.info { "Attempting to auto capture the payment" }

        if payment.capture!
          count = 0
          loop do
            break if @order.completed?
            break if count > 3  # Allow Max 3 iteration

            @order.next  
            count += 1
          end
          payment_received_notification(invoice)
        end
      else
        Rails.logger.info { "Payment not authorized or failed for Invoice #{invoice.invoice_number}"}
      end

    end

    private

    def payment_attributes
      {
        amount: @order.total,
        state: 'pending',
        source: payment_source,
        payment_method_id: payment_source.payment_method_id
      }
    end

    def payment_received_notification(invoice)

      args = {
            invoice: invoice,
            notification: 'invoice_payment_captured',
            user: invoice.user
          }
        
      AppManager::NotificationManager.new(args).call
    end

  end
end