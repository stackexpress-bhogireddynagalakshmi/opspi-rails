# frozen_string_literal: true

module StoreManager
  class StoreAdminCreator < ApplicationService
  	attr_reader :store,:account

    def initialize(store, options = {})
      @store = store
      @account = options[:account]
    end

    def call
      admin = Spree::User.find_by({email: store.admin_email}) || account.store_admin  
      admin = Spree::User.create({email: store.admin_email,:password=>store.admin_password,:password_confirmation=>store.admin_password}) if admin.blank?

      Sidekiq.redis{|conn|conn.set("spree_user_id_#{admin.id}_solid_cp", store.solid_cp_password)} if store.solid_cp_password.present?
      Sidekiq.redis{|conn|conn.set("spree_user_id_#{admin.id}_isp_config", store.solid_cp_password)} if store.isp_config_password.present?

      admin.update(
        :login => store.admin_email,
        :email=> store.admin_email,
        :isp_config_username=>store.isp_config_username
        )

      StoreManager::StoreAdminRoleAssignor.new(admin).call

      # TenantManager::UserTenantUpdater.new(admin,account.id).call

    end
    
  end
end