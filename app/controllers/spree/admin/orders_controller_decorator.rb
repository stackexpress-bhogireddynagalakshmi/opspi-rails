# frozen_string_literal: true

module Spree
  module Admin
    module OrdersControllerDecorator
      def index
        super
        if TenantManager::TenantHelper.current_admin_tenant? && current_spree_user.store_admin?
          @orders = @orders.where(account_id: current_spree_user.account_id) # rescue []
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
