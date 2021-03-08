class Subscription < ApplicationRecord
	belongs_to :user,:class_name=>'Spree::User'
	belongs_to :plan,:class_name=>'Spree::Product',:foreign_key=>'product_id'



	def self.subscribe!(opts)
		existing_subscription = self.where(status: true).first
	    if existing_subscription
	     	# 
	    else
	     	self.create do |s|
		      s.product_id      =  opts[:product].try(:id)
		      s.user_id = opts[:user].try(:id)
		      s.start_date = Date.today
		      s.end_date = Date.today + 1.year
		      s.price = opts[:product].price
		      s.status = true
		      s.frequency = 'ANNUAL'
		    end
	    end
	end
end
