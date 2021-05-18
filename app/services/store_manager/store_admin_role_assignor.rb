# frozen_string_literal: true

module StoreManager
  class StoreAdminRoleAssignor < ApplicationService
  	attr_reader :store_admin

    def initialize(store_admin, options = {})
      @store_admin = store_admin
    end

    def call
      role = Spree::Role.find_or_create_by({:name=>'store_admin'})
      store_admin.spree_roles << role if !store_admin.spree_roles.include?(role)
      store_admin.save
    end

  end
end