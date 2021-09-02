class CustomInvoiceFinder

  def initialize(scope: nil, invoice_number: nil,order_id: nil)
    @scope = scope || Invoice
    @invoice_number = invoice_number
    @order_id       = order_id 
  end

  def execute
    by_invoice_number || by_order_id
  end

  def present?
    execute
  end

  # def unscoped
  #   TenantManager::TenantHelper.unscoped_query do
  #    execute
  #   end
  # end

  def unscoped_execute
    TenantManager::TenantHelper.unscoped_query do
     execute
    end
  end

  protected

  attr_reader :scope, :url

  def by_invoice_number
    @scope.find_by_invoice_number(@invoice_number)
  end

  def by_order_id
    TenantManager::TenantHelper.unscoped_query do
      @scope.find_by_order_id(@order_id)
    end
  end

end
