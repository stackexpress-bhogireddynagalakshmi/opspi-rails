# frozen_string_literal: true

module Spree
  module Admin
    module OrdersControllerDecorator
      include ApplicationHelper

      def self.prepended(base)
        base.before_action :ensure_user_confirmed, except: [:show, :index, :new, :update]
      end
      
      def index
        super
        
        if TenantManager::TenantHelper.current_admin_tenant? && current_spree_user.store_admin?
          if current_spree_user.account_id != TenantManager::TenantHelper.admin_tenant_id
            @orders = @orders.where(account_id: current_spree_user.account_id)
          else
            @orders = @orders.where(account_id: -1)
          end
        elsif current_spree_user.end_user?
          @orders = @orders.where(user_id: current_spree_user.id)
        elsif current_spree_user.store_admin?
          @orders = @orders.where(account_id: current_spree_user.account_id)
        end
      end

      def edit
        ActsAsTenant.current_tenant = nil
      end
    end
  end
end

if ::Spree::Admin::OrdersController.included_modules.exclude?(Spree::Admin::OrdersControllerDecorator)
  ::Spree::Admin::OrdersController.prepend Spree::Admin::OrdersControllerDecorator
end
