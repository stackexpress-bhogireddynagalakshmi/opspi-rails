module Spree
    module PaypalControllerDecorator
      def confirm
        TenantManager::TenantHelper.unscoped_query {super}
      end

       def line_item(item)
          TenantManager::TenantHelper.unscoped_query {super}
       end
    end
end

::Spree::PaypalController.prepend Spree::PaypalControllerDecorator if ::Spree::PaypalController.included_modules.exclude?(Spree::PaypalControllerDecorator)
