class BillingPeriod
  attr_reader :subscription

  def initialize(subscription)
    @subscription = subscription
    @billing_period = TimeProvider.current_period
  end    

  def start
    return unless subscription

    last_invoice = subscription.invoices.where.not(status: ['final','archived']).last

    return (last_invoice.finished_on + 1.day) if last_invoice.present?

    return subscription.start_date

    #@billing_period.begin+subscription.current_started_on_day.days
  end

  def begin
    start
  end

  def end
    return unless start

    validity = subscription.validity || Subscription::DEFAULT_VALIDITY_DAYS

    start + validity.days
  end

end