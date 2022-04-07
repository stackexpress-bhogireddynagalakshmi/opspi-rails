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
      return nil unless invoice.present?
      return nil unless invoice.active?

      if @subscription.plan.hsphere?
        suspension_date = (invoice.started_on + 2.month).to_date # for hsphere suspension date is one month
      else
        suspension_date = invoice.due_date.to_date
      end

      if Date.today > suspension_date && @subscription.panel_disabled_at.blank?
        AppManager::PanelAccessDisabler.new(invoice).call        
      else
        send_invoice_reminder_notification if invoice_is_in_grace_period
      end
    end

    private


    # if reminder is not yet sent then send first reminder and save the date
    # if first reminder is already sent then wait for next 3 days and send again
    #  continue reminding the same unless  pannel access are disabled

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
       # due date is generay 7 day ahead of invoice creation/start date
       # and if due date has been passed then subscription is in grace perood

      return true if Date.today > invoice.due_date
      return false
    end

  end
end