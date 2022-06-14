# frozen_string_literal: true

class BillingPeriod
  attr_reader :subscription

  def initialize(subscription)
    @subscription = subscription
    @billing_period = TimeProvider.current_period
  end

  def start
    return unless subscription

    last_invoice = subscription.invoices.where.not(status: %w[final archived]).last

    return (last_invoice.finished_on + 1.day) if last_invoice.present?  

    subscription.start_date
  end

  def begin
    start
  end

  def end
    return unless start

    validity = subscription.validity || Subscription::DEFAULT_VALIDITY_MONTHS

    if start.month == 1 && [29,30,31].include?(start.day) 
      start + validity.months # 28th of feb
    else
      start + validity.months - 1.day
    end

  end
end
