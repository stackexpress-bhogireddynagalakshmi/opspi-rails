module Spree
	module LineItemDecorator
		def self.prepended(base)
	    	base.validate :ensure_no_more_than_one_plan_added_for_linux, if: -> { order.present? }
	    	base.validate :ensure_no_more_than_one_plan_added_for_solid_cp, if: -> { order.present? }
		end

		def ensure_valid_quantity
	     self.quantity = 1 if self.quantity !=1 && self.quantity > 0
	  end

	  def ensure_no_more_than_one_plan_added_for_linux
	  	count = 0
	  	order.line_items.each do |line_item|
				count+=1 if line_item.product.subscribable? && line_item.product.linux?          
      end

      return if count < 2

      errors.add(:error,'You already have added one plan for linux shared hosting in your cart.')

    end

    def ensure_no_more_than_one_plan_added_for_solid_cp
	  	count = 0
	  	order.line_items.each do |line_item|
				count+=1 if line_item.product.subscribable? && line_item.product.windows?          
      end

      return if count < 2

      errors.add(:error,'You already have added one plan for windows shared hosting in your cart.')

    end

	end
end


::Spree::LineItem.prepend Spree::LineItemDecorator if ::Spree::LineItem.included_modules.exclude?(Spree::LineItemDecorator)
