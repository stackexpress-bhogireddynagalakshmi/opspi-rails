# frozen_string_literal: true

module Spree
  module ProductsControllerDecorator
    def index
      @products = current_store.try(:account).try(:spree_products).where(subscribable: true)
    end

    def load_product
        TenantManager::TenantHelper.unscoped_query{super}
    end
  end
end

if ::Spree::ProductsController.included_modules.exclude?(Spree::ProductsControllerDecorator)
  ::Spree::ProductsController.prepend Spree::ProductsControllerDecorator
end
