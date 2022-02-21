# frozen_string_literal: true

module Spree
  module PaymentMethodDecorator
    def self.prepended(base)
      # base.acts_as_tenant :account,:class_name=>'::Account'
      base.belongs_to :account, class_name: '::Account'
      base.after_commit :add_to_tenant, on: %i[create update]
      base.after_commit :update_store_payment_methods, on: %i[create update]

      base.acts_as_list scope: [:account_id]
    end

    def add_to_tenant
      return unless respond_to?(:account_id)

      current_tenant = TenantManager::TenantHelper.current_tenant

      tenant_id = current_tenant.present? ? current_tenant.id : TenantManager::TenantHelper.admin_tenant.id

      Rails.logger.info { "update_tenant_id: #{tenant_id}" }

      TenantManager::PaymentMethodTenantUpdater.new(self, tenant_id).call
    rescue StandardError => e
      Rails.logger.error { e.message }
    end

    def update_store_payment_methods
      current_store = if TenantManager::TenantHelper.current_tenant.blank?
                        TenantManager::TenantHelper.admin_tenant&.spree_store
                      else
                        TenantManager::TenantHelper.current_tenant&.spree_store
                      end
      stores << current_store unless stores.include?(current_store)
    rescue StandardError => e
      Rails.logger.error { e.message }
    end
  end
end

if ::Spree::Address.included_modules.exclude?(Spree::PaymentMethodDecorator)
  ::Spree::PaymentMethod.prepend Spree::PaymentMethodDecorator
end

Spree::PermittedAttributes.store_attributes.push << :position
