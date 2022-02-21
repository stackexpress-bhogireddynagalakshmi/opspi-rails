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
        if current_spree_user.present? #&& current_spree_user.store_admin?

         @order  =  current_order || current_spree_user.orders.incomplete.includes(line_items: [variant: [:images, :product, option_values: :option_type]]).find_or_initialize_by(token: cookies.signed[:token])

        else
          @order = current_store.orders.incomplete.includes(line_items: [variant: [:images, :product, option_values: :option_type]]).
               find_or_initialize_by(token: cookies.signed[:token])

          associate_user
        end
      end
    end

    def show
      TenantManager::TenantHelper.unscoped_query {super}
    end

    def order_pdf
      file_path = "#{Rails.root}/tmp/order_pdf.pdf"
      @order = Spree::Order.last

      OrdersPdf.new(@order, file_path).call
      if File.exist?(file_path)
        File.open(file_path, 'r') do |f|
          send_data f.read.force_encoding('BINARY'), :filename => 'order.pdf', :type => "application/pdf", :disposition => "inline"
        end
        File.delete(file_path)
      else
        render plain: 'Could not print'
      end
      
    end
  end
end

::Spree::OrdersController.prepend Spree::OrdersControllerDecorator if ::Spree::OrdersController.included_modules.exclude?(Spree::OrdersControllerDecorator)
