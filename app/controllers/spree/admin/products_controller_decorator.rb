# frozen_string_literal: true

module Spree
  module Admin
    module ProductsControllerDecorator
      def collection
        super
        if TenantManager::TenantHelper.current_admin_tenant? && current_spree_user.store_admin?
          @collection = begin
            @collection.where(account_id: current_spree_user.account_id)
          rescue StandardError
            []
          end
        else
          super
        end
      end

      protected

      def location_after_save
        params.key?(:done) ? admin_products_path : edit_admin_product_url(@product)
      end
    end
  end
end

if ::Spree::Admin::ProductsController.included_modules.exclude?(Spree::Admin::ProductsControllerDecorator)
  ::Spree::Admin::ProductsController.prepend Spree::Admin::ProductsControllerDecorator
end
