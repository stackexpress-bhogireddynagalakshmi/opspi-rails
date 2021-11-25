module Spree
  module Admin
      module PaymentMethodsControllerDecorator

        def index
          @payment_methods = @payment_methods.where(account_id: tenant_id)
        end 

        def find_resource
          if parent_data.present?
            parent.send(controller_name).where(account_id: tenant_id).find(params[:id])
          else
            base_scope = model_class.try(:for_store, current_store) || model_class
            base_scope.where(account_id: tenant_id).find(params[:id])
          end
        end

        private

        def tenant_id
          if TenantManager::TenantHelper.current_tenant.present?
            TenantManager::TenantHelper.current_tenant.id
          else
            TenantManager::TenantHelper.admin_tenant.id
          end
        end

      end
   end
end

::Spree::Admin::PaymentMethodsController.prepend Spree::Admin::PaymentMethodsControllerDecorator if ::Spree::Admin::PaymentMethodsController.included_modules.exclude?(Spree::Admin::PaymentMethodsControllerDecorator)