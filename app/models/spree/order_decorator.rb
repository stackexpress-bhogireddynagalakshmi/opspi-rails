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
	end
end
::Spree::Order.prepend Spree::OrderDecorator if ::Spree::Order.included_modules.exclude?(Spree::OrderDecorator)
