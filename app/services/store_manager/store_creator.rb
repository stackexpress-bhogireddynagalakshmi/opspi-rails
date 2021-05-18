# frozen_string_literal: true

module StoreManager
  class StoreCreator < ApplicationService
  	attr_reader :store_params,:store_admin

    def initialize(store_admin, options = {})
      @store_admin = store_admin
    end

    def call
  		store = Spree::Store.new(store_params)
  		store.save! 
  		store.reload
      ensure_store_admin_role
      ensure_tenant_service_created(store)
    end


    def store_params
    	store_params = {name: store_admin.business_name,admin_email: store_admin.email,url: store_admin.subdomain,
  					mail_from_address: store_admin.email,code: store_admin.business_name&.underscore,default_currency: 'USD'}

    end

    def ensure_store_admin_role
    	StoreManager::StoreAdminRoleAssignor.new(store_admin).call
    end

    def ensure_tenant_service_created(store)
       TenantService.find_or_create_by({user_id: store_admin.id,account_id: store.account_id})
    end

  end
end

