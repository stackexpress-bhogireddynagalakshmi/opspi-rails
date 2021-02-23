module Spree
	module OrderDecorator
		def self.prepended(base)
	    	base.acts_as_tenant :account
	  	end
	end
end
::Spree::Order.prepend Spree::OrderDecorator if ::Spree::Order.included_modules.exclude?(Spree::OrderDecorator)
