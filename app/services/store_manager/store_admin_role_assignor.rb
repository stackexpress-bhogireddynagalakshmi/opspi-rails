# frozen_string_literal: true

module StoreManager
  class StoreAdminRoleAssignor < ApplicationService
  	attr_reader :store_admin

    def initialize(store_admin, options = {})
      @store_admin = store_admin

      if store_admin.email == ENV['ADMIN_EMAIL']
        @role  = 'admin'
      else
        @role = options[:role].present? ? options[:role] : 'store_admin'
      end
    end

    def call
      role = Spree::Role.find_or_create_by({:name=>@role})
      store_admin.reload
      store_admin.spree_roles << role if !store_admin.spree_roles.include?(role)
      store_admin.save
    end

  end
end