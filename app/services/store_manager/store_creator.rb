# frozen_string_literal: true

module StoreManager
  class StoreCreator < ApplicationService
    attr_reader :store_params,:store_admin,:store

    def initialize(store_admin, options = {})
      @store_admin = store_admin
      initialize_store
    end

    def call  
      if store.save
        store.reload
        ensure_store_admin_role
        ensure_tenant_service_created(store)
      end
    end

    def valid?
      store.valid?
    end

    private

    def initialize_store
      @store = Spree::Store.new(store_params)
      store_code = StoreManager::StoreCodeGenerator.new(store_admin.business_name&.underscore).call
      @store.code = store_code
    end

    def store_params
      subdomain = store_admin.subdomain.split(".")[0]
      url = "#{subdomain}.#{ENV['BASE_DOMAIN']}"
      
      store_params = {name: store_admin.business_name,admin_email: store_admin.email,url: url,
            mail_from_address: ENV['MAIL_FROM'],default_currency: 'USD'}
    end

    def ensure_store_admin_role
      StoreManager::StoreAdminRoleAssignor.new(store_admin).call
    end

    def ensure_tenant_service_created(store)
       TenantService.find_or_create_by({user_id: store_admin.id,account_id: store.account_id})
    end

  end
end

