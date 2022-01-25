class Subscription < ApplicationRecord
  belongs_to :user,:class_name=>'Spree::User'
  belongs_to :plan,:class_name=>'Spree::Product',:foreign_key=>'product_id'
  has_many :invoices

  scope :active, -> {where(status: true) }
  
  # enum frequency: {
  #   monthly: 0,
  #   quaterly: 1,
  #   half_yearly: 2,
  #   yearly: 3
  # } 


  DEFAULT_VALIDITY_DAYS = 30

  def self.subscribe!(opts)
    existing_subscription = self.where(status: true,user_id: opts[:user].try(:id),product_id: opts[:product].try(:id)).first
      if existing_subscription.present?
        validity = opts[:product].try(:validity) || DEFAULT_VALIDITY_DAYS
        existing_subscription.update({status: true, start_date: Date.today, end_date: Date.today + validity.days})
      else
        self.create_fresh_subscription(opts)
        AppManager::AccountProvisioner.new(opts[:user],product: opts[:product],order: opts[:order]).call
      end
  end

  def self.create_fresh_subscription(opts)
    TenantManager::TenantHelper.unscoped_query do

    validity = opts[:product].try(:validity) || DEFAULT_VALIDITY_DAYS

    subscription =  self.create({
      product_id:   opts[:product].try(:id),
      user_id:      opts[:user].try(:id),
      start_date:   Date.today,
      end_date:     Date.today + validity.days,
      price:        opts[:product].price,
      status:       true,
      frequency:    'monthly',
      validity:     validity
    })

    InvoiceManager::InvoiceCreator.new(subscription,{ payment_captured: true,order: opts[:order] }).call

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
    day -=1 
    day -=1 if day == 30
    day -=1 if Date.today.year % 4 == 0 && day == 27

    day
  end


  def control_panel_disabled?
    panel_disabled_at.present?
  end

  def current_unpaid_invoice
    invoice = InvoiceFinder.new(scope: self,billing_period: BillingPeriod.new(self)).execute

    return unless invoice.present?
    return unless invoice.active?

    return invoice
  end

end
