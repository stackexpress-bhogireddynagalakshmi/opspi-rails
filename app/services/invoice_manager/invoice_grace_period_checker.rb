module InvoiceManager
  class InvoiceGracePeriodChecker < ApplicationService
    attr_reader :invoice

    def initialize(invoice,options={})
      Rails.logger.info { "AccountGracePeriodChecker initialized"}
      @invoice = invoice
     
    end

    def call
      Rails.logger.info { "AccountGracePeriodChecker called"}
      return unless invoice.present?
      return unless invoice.active?

      if Date.today > invoice.due_date.to_date
        AppManager::PanelAccessDisabler.new(invoice).call        
      else
        send_invoice_reminder_notification
      end
    end

    private

    def send_invoice_reminder_notification

      if invoice.last_reminder_sent_at.blank? || invoice.last_reminder_sent_at.to_date + 3.day <= Date.today
        args = {
            invoice: invoice,
            notification: 'unpaid_invoice_reminder',
            user: invoice.user
          }
        
        AppManager::NotificationManager.new(args).call
      end
    end

  end
end