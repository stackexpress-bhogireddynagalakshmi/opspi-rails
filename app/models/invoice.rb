class Invoice < ApplicationRecord
  include AASM

  acts_as_tenant :account,:class_name=>'::Account'
  belongs_to :user,foreign_key: :user_id,class_name: 'Spree::User'
  belongs_to :subscription
  has_one :order,class_name: 'Spree::Order', primary_key: 'order_id', foreign_key: 'id',dependent: :destroy

  delegate :plan,to: :subscription

  before_validation :ensure_name
  before_validation :set_invoice_number

  validates_presence_of :name, :started_on, :finished_on, :invoice_number
  validates :finalized_at, presence: true, if: ->(i) { i.final? }




  aasm :status, column: 'status'  do
    state :active, initial: true
    state :processing
    state :final
    state :closed

    event :process, before: :ensure_processable_or_fail do
      transitions from: :active, to: :processing
    end

    # event :finalize, before: :ensure_finalizable_or_fail, after: :set_finalized_at do
    #   transitions from: :active, to: :final 
    #   transitions from: :processing, to: :final
    # end

    event :close, after: :set_closed_at do
      transitions from: [:active,:processing,:closed], to: :closed
    end

    event :reopen do
      transitions from: :closed, to: :final
    end
    
  end


  def can_process?
    active? && billing_period_started?
  end

  def can_finalize?
    (active? || processing?) && billing_period_started?
  end

  

  def ensure_processable_or_fail
    # if can_process? && can_run_invoice_finalizer?
    #   self.processing_started_on = Time.current
    #   true
    # else
    #   Rails.logger.error("Someone tried to process an #{Invoice.model_name.human} before it was ready! Not cool: #{Invoice.model_name.human} #{id}")
    #   raise InvoiceError, 'Invoice not ready for process!'
    # end

    return true
  end


  def ensure_finalizable_or_fail
    # if can_finalize?
    #   true
    # else
    #   Rails.logger.error("Someone tried to finalize an #{Invoice.model_name.human} before it was ready! Not cool: #{Invoice.model_name.human} #{id}")
    #   raise InvoiceError, 'Invoice not ready for finalization!'
    # end

    return true
  end

  def billing_period_started?
    Date.current.end_of_month >= started_on
  end

  def billing_month
    posting_date.strftime('%B')
  end

  def billing_year
    posting_date.strftime('%Y')
  end

  def posting_date
    started_on
  end

  def payment_date
    finished_on.next_day
  end

  def set_finalized_at
    self.balance = amount
    self.finalized_at = Time.current
  end

  def set_closed_at
    self.closed_at = Time.current
  end

  def action_at
    if final? && finalized_at
      invoice.finalized_at
    elsif invoice.closed? && invoice.closed_at
      invoice.closed_at
    end
  end

  def line_items
    active_subscription = user.subscriptions.active.map(&:plan)
  end

  # Used to check if invoice status can be changed from  active to processing without touching/updating the database
  def can_run_invoice_finalizer?
    InvoiceManager::InvoiceFinalizer.new(self).try_finalize
  end

  private

  def set_invoice_number
    self.invoice_number ||= compute_invoice_number
  end

  def ensure_name
    if account && posting_date
      plan = TenantManager::TenantHelper.unscoped_query { subscription.plan }
      self.name  = "#{billing_month} Invoice for  #{plan.name}"
    end
  end

  def compute_invoice_number
    SecureRandom.uuid.to_i(16).to_s(10)
  end

  def amount
    result = line_items.map(&:price).reduce(&:+)
    result = 0 if result.nil?
    result
  end

  class InvoiceError <  StandardError; end
end
