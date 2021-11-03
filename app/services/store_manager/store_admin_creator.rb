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

      admin = Spree::User.create!({email: store.admin_email,:password=>admin_password,:password_confirmation=>admin_password}) if admin.blank?
      
      Sidekiq.redis{|conn|conn.set("spree_user_id_#{admin.id}_solid_cp", store.solid_cp_password)} if store.solid_cp_password.present?
      Sidekiq.redis{|conn|conn.set("spree_user_id_#{admin.id}_isp_config", store.solid_cp_password)} if store.isp_config_password.present?

      admin.update(
        :login => store.admin_email,
        :email=> store.admin_email
      )

      StoreManager::StoreAdminRoleAssignor.new(admin).call

      admin

    end

    def admin_password
      return store.admin_password if store.admin_password.present?

      store.admin_password = Devise.friendly_token.first(8)
    end
    
  end
end