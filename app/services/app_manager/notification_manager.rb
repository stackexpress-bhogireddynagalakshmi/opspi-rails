# frozen_string_literal: true

module AppManager
  #Notification Manager Class
  class NotificationManager < ApplicationService
    def initialize(args)
      @args         = args
      @notification = args.fetch(:notification)
      @user         = args.fetch(:user)
    end

    def call
      send("user_#{@notification}")
    end

    def user_unpaid_invoice_reminder
      invoice = @args.fetch(:invoice)
      pending_invoices = @args.fetch(:pending_invoices)

      NotificationMailer.with(
        invoice: invoice,
        user:    invoice.user,
        pending_invoices: pending_invoices
        )
      .unpaid_invoice_reminder
      .deliver

      invoice.update(last_reminder_sent_at: Time.zone.now)
    end

    def user_pannel_access_disabled
      invoice = @args.fetch(:invoice)
      panel   = @args.fetch(:panel)

      NotificationMailer.with(
        invoice: invoice,
        user:    invoice.user,
        panel:   panel
        )
      .pannel_access_disabled
      .deliver
    end

    def user_pannel_access_enabled
      invoice = @args.fetch(:invoice)
      panel   = @args.fetch(:panel)

      NotificationMailer.with(
        invoice: invoice,
        user:    invoice.user,
        panel:   panel
        )
      .pannel_access_enabled
      .deliver
    end

    def user_invoice_payment_captured
      invoice = @args.fetch(:invoice)
     
      NotificationMailer.with(
        invoice: invoice,
        user:    invoice.user
        )
      .invoice_payment_captured
      .deliver
    end
  end
end
