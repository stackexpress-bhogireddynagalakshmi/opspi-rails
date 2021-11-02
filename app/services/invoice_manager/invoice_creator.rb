module InvoiceManager
  class InvoiceCreator < ApplicationService
    attr_reader :user,:subscription, :billing_period,:payment_captured

    def initialize(subscription, opts={})
      @subscription       = subscription
      @user               = @subscription.user
      @billing_period     ||= BillingPeriod.new(subscription)
      @payment_captured   = opts[:payment_captured] || false
      @order              = opts[:order]
    end

    def call
      ActiveRecord::Base.transaction do
        invoice = create_invoice
        add_fees_to_invoice(invoice)
        # create_order_for_invoice(invoice)
        if payment_captured
          # invoice.finalize! if invoice.may_finalize?
          invoice.close! if invoice.may_close?
          invoice.update_column :order_id, @order.id if @order.present?
        end
      end
    end

    def create_invoice
      invoice ||= find_current_invoice

      if invoice.blank?
        invoice = Invoice.create!(invoice_params)
        Rails.logger.info { "New Invoice created: #{invoice.name} for #{user.email}"}
      else
        Rails.logger.info { "Invoice Exists: #{invoice.name} for #{user.email}" }
        #raise "Invoice already exists."
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

      { user: user,
        subscription: subscription,
        started_on:  billing_period.start,
        finished_on: billing_period.end,
        account:     user.account,
        due_date:    billing_period.end + DUE_DAYS.days
      }
    end

    def add_fees_to_invoice(invoice)
      InvoiceFeeCalculator.new(invoice).calculate_and_save
    end

    def current_invoice_finder
      InvoiceFinder
    end

    def find_current_invoice
      last_invoice = subscription.invoices.active.last

      return last_invoice if last_invoice &&  last_invoice.finished_on > Date.today 

    end
  end
end