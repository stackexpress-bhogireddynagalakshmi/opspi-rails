module InvoiceManager
  class InvoiceGracePeriodChecker < ApplicationService
    attr_reader :invoice, :pending_invoices

    def initialize(invoice, options={})
      Rails.logger.info { "AccountGracePeriodChecker initialized"}
      @invoice = invoice
      @pending_invoices = options[:pending_invoices] || []
      @subscription = invoice.subscription
    end

    def call
      Rails.logger.info { "AccountGracePeriodChecker called"}
      return unless invoice.present?
      return unless invoice.active?

      if Date.today > invoice.due_date.to_date && @subscription.panel_disabled_at.blank?
        AppManager::PanelAccessDisabler.new(invoice).call        
      else
        send_invoice_reminder_notification if invoice_is_in_grace_period
      end
    end

    private

    def send_invoice_reminder_notification
      if invoice.last_reminder_sent_at.blank? || invoice.last_reminder_sent_at.to_date + 3.day <= Date.today
        args = {
            invoice: invoice,
            notification: 'unpaid_invoice_reminder',
            user: invoice.user,
            pending_invoices: pending_invoices
          }
        
        AppManager::NotificationManager.new(args).call
      end
    end

    def invoice_is_in_grace_period
      return true if Date.today > invoice.finished_on

      return false
    end

  end
end