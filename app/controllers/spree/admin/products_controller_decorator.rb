module Spree
  module Admin
    module ProductsControllerDecorator
      def collection
        if TenantManager::TenantHelper.current_admin_tenant? && current_spree_user.store_admin?
         super
          @collection = @collection.where(account_id: current_spree_user.account_id) rescue []
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

::Spree::Admin::ProductsController.prepend Spree::Admin::ProductsControllerDecorator if ::Spree::Admin::ProductsController.included_modules.exclude?(Spree::Admin::ProductsControllerDecorator)


