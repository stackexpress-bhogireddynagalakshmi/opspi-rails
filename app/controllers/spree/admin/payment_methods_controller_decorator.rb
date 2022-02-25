# frozen_string_literal: true

module Spree
  module Admin
    module PaymentMethodsControllerDecorator
      def index
        @payment_methods = @payment_methods.where(account_id: tenant_id)
      end

      ## Todo: Need to customize in callback way
      def update
        invoke_callbacks(:update, :before)
        payment_method_type = params[:payment_method].delete(:type)
        if @payment_method['type'].to_s != payment_method_type
          @payment_method.update_columns(
            type: payment_method_type,
            updated_at: Time.current
          )
          @payment_method = PaymentMethod.find(params[:id])
        end
        attributes = payment_method_params.merge(preferences_params)
        attributes.each do |k, _v|
          attributes.delete(k) if k.include?('password') && attributes[k].blank?
        end

        if @payment_method.update(attributes)
          invoke_callbacks(:update, :after)
          flash[:success] = Spree.t(:successfully_updated, resource: Spree.t(:payment_method))
          redirect_to params.key?(:done) ? admin_payment_methods_path : edit_admin_payment_method_path(@payment_method)
        else
          invoke_callbacks(:update, :fails)
          respond_with(@payment_method)
        end
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

if ::Spree::Admin::PaymentMethodsController.included_modules.exclude?(Spree::Admin::PaymentMethodsControllerDecorator)
  ::Spree::Admin::PaymentMethodsController.prepend Spree::Admin::PaymentMethodsControllerDecorator
end
