module Spree
	module LineItemDecorator

		def ensure_valid_quantity
	      	self.quantity = 1 if self.quantity !=1 && self.quantity > 0
	    end

	end
end


::Spree::LineItem.prepend Spree::LineItemDecorator if ::Spree::LineItem.included_modules.exclude?(Spree::LineItemDecorator)
