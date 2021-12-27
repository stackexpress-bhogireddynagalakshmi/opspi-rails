module InvoiceManager
  class OrderCreator < ApplicationService
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

          InvoiceManager::InvoiceUpdater.new(invoice, { params: { order_id: order.id }}).call
        end

        invoice.reload.order
      rescue Exception => e
        Rails.logger.error {e.message}
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

    def order_params
      { 
        currency:   current_currency,
        user_id:    user.id,
        store_id:   store_id,
        account_id: account_id,
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
      user.bill_address_id
    end

    def ship_address_id
      user.ship_address_id
    end

    def account_id
      if user.store_admin?
        TenantManager::TenantHelper.admin_tenant_id
      else
        user.account_id
      end
    end

    def store_id
      if user.store_admin?
        TenantManager::TenantHelper.admin_tenant.spree_store.id
      else
        user.account.spree_store.id
      end
    end
    
  end
end