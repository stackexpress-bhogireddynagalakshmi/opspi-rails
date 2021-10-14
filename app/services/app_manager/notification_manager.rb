# frozen_string_literal: true

module AppManager
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

      NotificationMailer.with(
        invoice: invoice,
        user:    invoice.user
        )
      .unpaid_invoice_reminder
      .perform_later

      invoice.update(last_reminder_sent_at: Time.zone.now)
      
    end

    def user_pannel_access_disabled
      invoice = @args.fetch(:invoice)

      NotificationMailer.with(
        invoice: invoice,
        user:    invoice.user
        )
      .pannel_access_disabled
      .perform_later

    end

  end
end
