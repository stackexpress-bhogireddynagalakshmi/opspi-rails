module InvoiceManager
  class OrderCreator
    attr_reader :invoice,:user

    def initialize(invoice)
      @invoice = invoice
      @user = invoice.user
    end
    
    def call
      begin
        if invoice.order.blank?    
          order = Spree::Order.create!(order_params)
          
          add_item_service.call(
              order: order,
              variant: invoice.plan.master,
              quantity: 1,
              options: {}
            )
          InvoiceManager::InvoiceUpdater.new(invoice,{params: {order_id: order.id}}).call
        end

        invoice.reload.order
      rescue Exception => e
        puts e.message    
      end
    end

    private

    def current_currency
      if invoice.account.spree_store.present?
         invoice.account.spree_store.default_currency
      else
         Spree::Config[:currency]
      end&.upcase
    end

    def store_id
      if user.store_admin?
        TenantManager::TenantHelper.admin_tenant_id
      else
        user.account.spree_store.id
      end
    end

    def order_params
      { 
        currency:   current_currency,
        user_id:    user.id,
        store_id:   store_id,
        state:      'address', 
        email:      user.email,
        order_type: 'auto',
        bill_address_id: bill_address_id,
        ship_address_id: ship_address_id
      }
    end

    def add_item_service
      Spree::Api::Dependencies.storefront_cart_add_item_service.constantize
    end

    def bill_address_id
      user.orders.complete.last.bill_address_id
    end

    def ship_address_id
      user.orders.complete.last.bill_address_id
    end

  end
end