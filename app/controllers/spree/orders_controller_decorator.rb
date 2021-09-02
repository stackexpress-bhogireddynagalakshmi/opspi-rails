module Spree
  
  module OrdersControllerDecorator
    def edit
      if params[:invoice_number].present?
        invoice = CustomInvoiceFinder.new(invoice_number: params[:invoice_number]).unscoped_execute
        super unless invoice
        super if invoice.closed?

        TenantManager::TenantHelper.unscoped_query  do
          @order = InvoiceManager::OrderCreator.new(invoice).call
          cookies.signed[:token] = @order.token
        end


      else
        if current_spree_user.store_admin?
         @order =  current_spree_user.orders.incomplete.
          includes(line_items: [variant: [:images, :product, option_values: :option_type]]).find_or_initialize_by(token: cookies.signed[:token])
        else
          @order = current_order || current_store.orders.incomplete.
               includes(line_items: [variant: [:images, :product, option_values: :option_type]]).
               find_or_initialize_by(token: cookies.signed[:token])
          associate_user
        end
      end
    end

    def show
     TenantManager::TenantHelper.unscoped_query {super}
    end
  end
end

::Spree::OrdersController.prepend Spree::OrdersControllerDecorator if ::Spree::OrdersController.included_modules.exclude?(Spree::OrdersControllerDecorator)
