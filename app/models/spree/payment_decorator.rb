module Spree
	module PaymentDecorator

		def self.prepended(base)
			base.state_machine initial: :checkout do
		 	   after_transition to: :completed, do: [:create_subscriptions!]
		 	end

      base.validates :check_number,uniqueness: true, if: -> { check_number.present? }

	  end
	  	
  	# Issue in State machine
  	def create_subscriptions!
  	 	self.order.create_subscriptions(self)
  	 	puts "Create Subscription Executed"
  	end

	end
end

::Spree::Payment.prepend Spree::PaymentDecorator if ::Spree::Order.included_modules.exclude?(Spree::PaymentDecorator)
Spree::PermittedAttributes.payment_attributes.push << :check_number
