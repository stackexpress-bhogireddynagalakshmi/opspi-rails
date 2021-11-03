class InvoiceFinder
   #find invoice by billing period
   #scope is subscription object

  def initialize(scope: nil,billing_period:)
    @scope = scope
    @invoices = scope.invoices
    @billing_period = billing_period || BillingPeriod.new(scope)
  end

  def execute
    by_billing_period(scope) 
  end

  protected

  attr_reader :scope, :url

  def by_billing_period(scope)
    return if @billing_period.blank?

    invoice = @invoices.
              where(started_on: @billing_period.begin,
                    finished_on: @billing_period.end).
              first

  end
end
