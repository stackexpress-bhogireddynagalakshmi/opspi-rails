# frozen_string_literal: true

module Spree
  module StoreDecorator
    attr_accessor :admin_password, :solid_cp_password, :isp_config_username, :isp_config_password

    def self.prepended(base)
      base.after_commit :create_account_and_admin_user, on: %i[create update]
      base.belongs_to :account, class_name: '::Account'
      base.validates :url, uniqueness: true
      base.validates :admin_email, format: { with: URI::MailTo::EMAIL_REGEXP }
      base.validates :isp_config_username,
                     exclusion: {
                       in: %w[www mail ftp smtp imap download upload image service offline online admin root username webmail blog help
                              support], message: "%{value} is not a valid username."
                     }
    end

    def self.current(domain = nil)
      current_store = domain ? Store.by_url(domain).first : nil

      return current_store if domain.present && current_store.present?

      if TenantManager::TenantHelper.current_admin_tenant? || TenantManager::TenantHelper.current_tenant.blank?
        TenantManager::TenantHelper.admin_tenant.spree_store
      else
        TenantManager::TenantHelper.current_tenant.spree_store
      end
    end

    protected

    def create_account_and_admin_user
      ActiveRecord::Base.transaction do
        account = TenantManager::TenantCreator.new(self).call

        ::TenantManager::StoreTenantUpdater.new(self, account.id).call

        store_admin = StoreManager::StoreAdminCreator.new(self, account: account).call

        create_chatwoot_resources(store_admin)

        if TenantManager::TenantHelper.current_tenant.blank? || store_admin.account_id.blank?
          store_admin.update_column :account_id, account.id
        end
      end
    end

    def create_chatwoot_resources(store_admin)
      return nil if store_admin.account_id == ::TenantManager::TenantHelper.admin_tenant_id
      return nil if ChatwootUser.where(store_account_id: store_admin.account_id).any?
      return nil if Rails.env.test?

      StoreManager::ChatWootResourceCreator.new(self).call
    end
  end
end

::Spree::Store.prepend ::Spree::StoreDecorator if ::Spree::Store.included_modules.exclude?(::Spree::StoreDecorator)

%i[admin_email admin_password solid_cp_access solid_cp_password solid_cp_master_plan_id isp_config_access
   isp_config_username isp_config_password isp_config_master_template_id].each do |attr|
  Spree::PermittedAttributes.store_attributes.push << attr
end
