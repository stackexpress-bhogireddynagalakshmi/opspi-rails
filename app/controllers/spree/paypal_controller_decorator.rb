# frozen_string_literal: true

module Spree
  module PaypalControllerDecorator
    def confirm
      TenantManager::TenantHelper.unscoped_query { super }
    end

    def line_item(item)
      TenantManager::TenantHelper.unscoped_query { super }
    end
  end
end

if ::Spree::PaypalController.included_modules.exclude?(Spree::PaypalControllerDecorator)
  ::Spree::PaypalController.prepend Spree::PaypalControllerDecorator
end
