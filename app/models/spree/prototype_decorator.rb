# frozen_string_literal: true

module Spree
  module PrototypeDecorator
    def self.prepended(base)
      base.after_commit :ensure_account_id_updated, on: :create
    end

    private
    def ensure_account_id_updated
      account_id = if TenantManager::TenantHelper.current_admin_tenant? || TenantManager::TenantHelper.current_tenant.blank?
                    TenantManager::TenantHelper.admin_tenant.id
                  else
                    TenantManager::TenantHelper.current_tenant.id
                  end

      self.update_column(:account_id, account_id)
    end
  end
end

::Spree::Prototype.prepend Spree::PrototypeDecorator if ::Spree::Country.included_modules.exclude?(Spree::PrototypeDecorator)
