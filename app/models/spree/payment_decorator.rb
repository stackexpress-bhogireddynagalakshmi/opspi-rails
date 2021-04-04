module Spree
	module PaymentDecorator

		def self.prepended(base)

			base.state_machine initial: :checkout do
		 	   after_transition to: :completed, do: [:create_subscriptions!]
		 	end
	  	end
	  	
	  	# Issue in State machine
	  	def create_subscriptions!
    	 	self.order.create_subscriptions(self)
    	 	puts "Create Subscription Executed"
    	end

    	# Issue in after complete callback, called multiple times
    	# def provision_space
    	# 	self.order.line_items.each do |line_item|
		   #      if line_item.product.subscribable?
		   #      	ProvisioningJob.perform_later(self.order.user_id,line_item.product.id)
		   #      end
	    #   	end
	    #   	puts "ProvisioningJob Executed"
    	# end
	end
end

::Spree::Payment.prepend Spree::PaymentDecorator if ::Spree::Order.included_modules.exclude?(Spree::PaymentDecorator)

