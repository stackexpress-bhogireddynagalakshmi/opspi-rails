# frozen_string_literal: true

class Subscription < ApplicationRecord
  belongs_to :user, class_name: 'Spree::User'
  belongs_to :plan, class_name: 'Spree::Product', foreign_key: 'product_id'
  has_many :invoices

  delegate :server_type, to: :plan

  scope :active, -> { where(status: true) }

  # enum frequency: {
  #   monthly: 0,
  #   quaterly: 1,
  #   half_yearly: 2,
  #   yearly: 3
  # }

  DEFAULT_VALIDITY_DAYS = 1  # 1 month

  def self.subscribe!(opts)
    existing_subscription = where(status: true, user_id: opts[:user].try(:id),
                                  product_id: opts[:product].try(:id)).first

    if existing_subscription.present?
      validity = opts[:product].try(:validity) || DEFAULT_VALIDITY_DAYS
      existing_subscription.update({ status: true, end_date: Date.today + validity.months }) 
    else
      create_fresh_subscription(opts)
      AppManager::AccountProvisioner.new(opts[:user], product: opts[:product], order: opts[:order]).call
    end
  end

  def self.create_fresh_subscription(opts)
    TenantManager::TenantHelper.unscoped_query do
      validity   = opts[:product].try(:validity) || DEFAULT_VALIDITY_DAYS
      start_date = opts[:start_date].presence || Date.today
      end_date   = opts[:end_date].presence ||  start_date + validity.months

      subscription = create({
                              product_id:   opts[:product].try(:id),
                              user_id:      opts[:user].try(:id),
                              start_date:   start_date,
                              end_date:     end_date,
                              price:        opts[:product].price,
                              status:       true,
                              frequency:    opts[:frequency].presence || 'monthly',
                              validity:     validity
                            })

      payment_captured = if opts[:order].present?
                           opts[:order].payment_state == 'paid'
                        else
                          false
                        end

      InvoiceManager::InvoiceCreator.new(subscription, { payment_captured: payment_captured, order: opts[:order] }).call
    end
  end

  def active?
    status
  end

  def billing_interval
    frequency
  end

  def current_started_on_day
    day  = start_date.day
    day -= 1
    day -= 1 if day == 30
    day -= 1 if (Date.today.year % 4).zero? && day == 27

    day
  end

  def control_panel_disabled?
    panel_disabled_at.present?
  end

  def current_unpaid_invoice
    invoice = InvoiceFinder.new(scope: self, billing_period: BillingPeriod.new(self)).execute

    return unless invoice.present?
    return unless invoice.active?

    invoice
  end
end
