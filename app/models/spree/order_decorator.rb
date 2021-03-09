module Spree
	module OrderDecorator
		
		def self.prepended(base)
	    	base.acts_as_tenant :account
	    	base.checkout_flow do
			    go_to_state :address
			    go_to_state :payment, :if => lambda { |order| order.payment_required? }
			    go_to_state :confirm, :if => lambda { |order| order.confirmation_required? }
			    go_to_state :complete
			end
	  	end

	  	def create_subscriptions
	      line_items.each do |line_item|
	        if line_item.product.subscribable?
	          Subscription.subscribe!(
	           user: self.user,
	           product: line_item.product	            
	          )
	        end
	      end
	    end

	end
end

::Spree::Order.prepend Spree::OrderDecorator if ::Spree::Order.included_modules.exclude?(Spree::OrderDecorator)
