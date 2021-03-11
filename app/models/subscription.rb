class Subscription < ApplicationRecord
	belongs_to :user,:class_name=>'Spree::User'
	belongs_to :plan,:class_name=>'Spree::Product',:foreign_key=>'product_id'
	scope :active, -> {where(status: true) }



	def self.subscribe!(opts)
		existing_subscription = self.where(status: true,user_id: opts[:user].try(:id),product_id: opts[:product].try(:id)).first
	    if existing_subscription.present?
	     	existing_subscription.update({status: true})
	    else
	    	self.create_fresh_subscription(opts)
	    end
	end


	def self.create_fresh_subscription(opts)
		self.create({
    		product_id: opts[:product].try(:id),
    		user_id: opts[:user].try(:id),
    		start_date: Date.today,
		    end_date: Date.today + 1.year,
		    price:  opts[:product].price,
		    status:  true,
		    frequency:  'ANNUAL'
    	})
	end


	def active?
		status
	end

	def billing_interval
		frequency
	end
end
