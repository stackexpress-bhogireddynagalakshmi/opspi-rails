# frozen_string_literal: true

module Spree
  module Admin
    class DomainRegistrationsController < Spree::Admin::BaseController
      helper Spree::Admin::NavigationHelper
      include Spree::Admin::DomainRegistrationsHelper
      include ApplicationHelper

      before_action :ensure_user_confirmed, except: [:show, :index, :new]
      before_action :set_tld_pricing, only: [:new]
      before_action :ensure_reseller_club_configured, except: [:setup_reseller_club]
      

      def index
        
        ActsAsTenant.current_tenant = nil

        @orders = if current_spree_user.superadmin?
                    Spree::Order
                  else
                    spree_current_user.orders
                  end
        @orders = @orders.joins(line_items: [:product])
                         .where(spree_products: { server_type: 'domain' })
                         .select("spree_orders.*,spree_line_items.domain,spree_line_items.validity,spree_line_items.domain_successfully_registered,spree_line_items.domain_registered_at,spree_line_items.api_response")
                         .order('spree_orders.created_at desc')

        @domains = @orders
     
      end

      def new
        
        @order = current_domain_order
        cookies.signed[:token] = @order.token if @order.present?
        @product = TenantManager::TenantHelper.unscoped_query { Spree::Product.domain.first }
        @variant = @product.master
        if params[:domian_names].present?
            domains = params[:domian_names].split(",")
            tlds    = params[:tlds] || ["com"]

            @response = ResellerClub::Domain.available("domain-name" => domains, "tlds" => tlds,
                                                      'email' => current_spree_user.email)[:response]

            @suggestions = ResellerClub::Domain.v5_suggest_names("keyword" => params[:domian_names], "tlds" => tlds,
                                                               "hyphen-allowed" => "true", "add-related" => "true", "no-of-results" => "10", 'email' => current_spree_user.email)[:response]
        end

      end

      def create
        
        TenantManager::TenantHelper.unscoped_query do
          @product = Spree::Product.domain.first
          
          @order   = Spree::Order.find_by_id(params[:order_id]) || current_domain_order
          @variant = Spree::Variant.find(params[:variant_id])

          if @order.blank?
            @order = Spree::Order.create!(order_params)
            cookies.signed[:token] = @order.token
          end

          options = validate_pricing_for_domain(params[:options])

          @result = add_item_service.call(
            order: @order,
            variant: @variant,
            quantity: 1,
            options: options
          )
        end
      end

      def setup_reseller_club
        if request.post?
            spree_current_user.update(user_params)
            flash.now[:success] = "ResellerClub credentials saved successfully"
        end

        if current_spree_user.store_admin? || current_spree_user&.superadmin?
          render layout: "spree/layouts/admin"
        else
          render layout: "dashkit_admin_layout"
        end
      end

      def update_reseller_club
        spree_current_user.update(user_params)
        flash.now[:success] = I18n.t(:reseller_club_credentials_saved)

        redirect_to setup_reseller_club_admin_domain_registrations_url
      end

      private

      def set_tld_pricing
        response = ResellerClub::Product.customer_price('customer-id' => customer_id,
                                                        'email' => current_spree_user.email)

        @tld_pricing = if response[:success]
                         response[:response]
                       else
                         []
                       end
      end

      def order_params
        {
          currency: 'USD',
          user_id: spree_current_user.id,
          store_id: store_id,
          account_id: spree_current_user.account_id,
          state: 'address',
          email: spree_current_user.email,
          bill_address_id: spree_current_user.bill_address_id,
          ship_address_id: spree_current_user.ship_address_id
        }
      end

      def add_item_service
        Spree::Api::Dependencies.storefront_cart_add_item_service.constantize
      end

      def store_id
        if spree_current_user.store_admin?
          TenantManager::TenantHelper.admin_tenant.spree_store.id
        else
          spree_current_user.account.spree_store.id
        end
      end

      def current_domain_order
        TenantManager::TenantHelper.unscoped_query do
          Spree::Order.all
                      .incomplete
                      .joins(:products)
                      .where(spree_products: { server_type: 'domain' })
                      .where(spree_orders: { user_id: current_spree_user.id })
                      .where("Date(spree_orders.created_at) > ?", Date.today - 1.day)
                      .last
        end
      end

      def user_params
        user_key_attributes = [:id, :reseller_club_account_id, :_destroy]

        if params[:user][:user_key_attributes][:reseller_club_account_key_enc] != DUMMY_PASS
          user_key_attributes << :reseller_club_account_key_enc
        end

        params.require(:user).permit(:reseller_club_customer_id, :reseller_club_contact_id,
                                     user_key_attributes: user_key_attributes)
      end

      def customer_id
        current_spree_user.account.store_admin.reseller_club_customer_id
      rescue StandardError
        nil
      end

      def validate_pricing_for_domain(options)
        options  # TODO: calculate the pricing again and update the hash before saving into database
      end

      def ensure_reseller_club_configured
        return nil if current_spree_user.end_user?

        unless current_spree_user.account.reseller_club_configured?
           flash[:error] = I18n.t(:reseller_club_configuration_error) 
          redirect_to  setup_reseller_club_admin_domain_registrations_url  
        end
      end
    end
  end
end
