class Account < ApplicationRecord
	has_one :spree_store ,:class_name=>'Spree::Store'
	has_many :spree_products,:class_name=>'Spree::Product',dependent: :destroy
	has_many :spree_orders,:class_name=>'Spree::Order',dependent: :destroy
	has_many :users,:class_name=>'Spree::User',dependent: :destroy


	def store_admin
		users.select{|user| user.store_admin?}.first
	end

	def admin_tenant?
		TenantManager::TenantHelper.admin_tenant.id == self.id
	end

	
end
