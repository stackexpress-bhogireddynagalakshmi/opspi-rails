class Account < ApplicationRecord
	has_one :spree_store ,:class_name=>'Spree::Store'
	has_many :spree_products,:class_name=>'Spree::Product'
	has_many :users,:class_name=>'Spree::User'


	def store_admin
		users.select{|user| user.store_admin?}.first
	end

end
