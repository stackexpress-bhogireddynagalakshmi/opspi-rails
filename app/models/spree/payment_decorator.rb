module Spree
	module PaymentDecorator

		def self.prepended(base)
		  base.state_machine.after_transition to: :completed, do: :create_subscriptions!
	  	end


	  	def create_subscriptions!
      		self.order.create_subscriptions
    	end
	end
end

::Spree::Payment.prepend Spree::PaymentDecorator if ::Spree::Order.included_modules.exclude?(Spree::PaymentDecorator)

