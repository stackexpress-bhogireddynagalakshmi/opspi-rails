# frozen_string_literal: true

module InvoiceManager
  class InvoiceCreator < ApplicationService
    attr_reader :user, :subscription, :billing_period, :payment_captured

    def initialize(subscription, opts = {})
      @subscription       = subscription
      @user               = @subscription.user
      @billing_period ||= BillingPeriod.new(subscription)
      @payment_captured   = opts[:payment_captured] || false
      @order              = opts[:order]
    end

    def call
      ActiveRecord::Base.transaction do
        invoice = create_invoice
        add_fees_to_invoice(invoice)
        if payment_captured
          invoice.close! if invoice.may_close?
          invoice.update_column :order_id, @order.id if @order.present?
        end
      end
    end

    def create_invoice
      invoice ||= find_current_invoice

      if invoice.blank?
        invoice = Invoice.create!(invoice_params)
        Rails.logger.info { "New Invoice created: #{invoice.name} for #{user.email}" }
      else
        Rails.logger.info { "Invoice Exists: #{invoice.name} for #{user.email}" }
      end
      invoice
    end

    def create_order_for_invoice(invoice)
      InvoiceManager::OrderCreator.new(invoice).call
    end

    private

    DUE_DAYS = 7

    def invoice_params
      billing_period = BillingPeriod.new(subscription)
      {
        user: user,
        subscription: subscription,
        started_on: billing_period.start,
        finished_on: billing_period.end,
        account: user.account,
        due_date: billing_period.start + DUE_DAYS.days,
        deletion_date: billing_period.start + 3.months,
        suspension_date: get_suspention_date(billing_period)
      }
    end

    def add_fees_to_invoice(invoice)
      InvoiceFeeCalculator.new(invoice).calculate_and_save
    end

    def get_suspention_date(billing_period)
      suspension_date = if subscription.plan.hsphere?
                          (billing_period.start + 2.month).to_date # for hsphere suspension date is one month
                        else
                          billing_period.start + DUE_DAYS.days
                        end
    end

    # this method enusre that invoice should be only generated
    # if not already generated for the current billing period
    def find_current_invoice
      last_invoice = subscription.invoices.last
      return nil if last_invoice.blank?
      return nil if last_invoice.archived?
      return nil if Date.today > last_invoice.finished_on

      last_invoice
    end

    def current_invoice_finder
      InvoiceFinder
    end
  end
end
