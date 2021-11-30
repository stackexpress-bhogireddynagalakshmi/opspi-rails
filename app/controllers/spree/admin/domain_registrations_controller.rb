class Spree::Admin::DomainRegistrationsController < Spree::Admin::BaseController
   helper Spree::Admin::NavigationHelper

   def index
    ActsAsTenant.current_tenant = nil

    if current_spree_user.superadmin?
      @orders = Spree::Order
    else
      @orders = spree_current_user.orders
    end    
    @orders   = @orders.joins(line_items: [:product])
                          .where(spree_products: {server_type: 'domain'})
                          .select("spree_orders.*,spree_line_items.domain,spree_line_items.validity")
                          .order('spree_orders.created_at desc')
    
    @domains  =  @orders
   end


    def new
      @order = current_domain_order

      cookies.signed[:token] = @order.token if @order.present?
  
      @product = TenantManager::TenantHelper.unscoped_query { Spree::Product.domain.first }
 
      if params[:domian_names].present?
        domains = params[:domian_names].split(",")
        tlds    = params[:tlds]
        @response = ResellerClub::Domain.available("domain-name" => domains,"tlds" => tlds)[:response]

        @suggestions =  ResellerClub::Domain.v5_suggest_names("keyword" => params[:domian_names], "tlds" => tlds, "hyphen-allowed" => "true", "add-related" => "true", "no-of-results" => "10")[:response]
        
      end
    end

    def create
      TenantManager::TenantHelper.unscoped_query do
      @product = Spree::Product.domain.first
      @order   = Spree::Order.find_by_id(params[:order_id]) || current_domain_order
      @variant = Spree::Variant.find(params[:variant_id])

      if @order.blank?
        @order = Spree::Order.create!(order_params)
      end

     
      @result = add_item_service.call(
            order: @order,
            variant: @variant,
            quantity: 1,
            options: params[:options]
          )

      end
      #redirect_to  new_admin_domain_registration_path(order_id: @order.id,domian_names: params[:options][:domain],tlds: tlds)
    end



    private

    def order_params
      { 
        currency:   'USD',
        user_id:    spree_current_user.id,
        store_id:   store_id,
        account_id: spree_current_user.account_id,
        state:      'address', 
        email:      spree_current_user.email,
        bill_address_id: spree_current_user.bill_address_id,
        ship_address_id: spree_current_user.ship_address_id
      }
    end


    def add_item_service
      Spree::Api::Dependencies.storefront_cart_add_item_service.constantize
    end

    def store_id
      if spree_current_user.store_admin?
        TenantManager::TenantHelper.admin_tenant_id
      else
        spree_current_user.account.spree_store.id
      end
    end

    def current_domain_order
      TenantManager::TenantHelper.unscoped_query do
        Spree::Order.all
                    .incomplete
                    .joins(:products)
                    .where(spree_products: {server_type: 'domain'})
                    .where(spree_orders: {user_id: current_spree_user.id})
                     .last
      end
    end

end
